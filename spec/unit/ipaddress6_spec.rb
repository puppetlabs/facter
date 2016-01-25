#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

def ifconfig_fixture(filename)
  File.read(fixtures('ifconfig', filename))
end

describe "The IPv6 address fact" do
  include FacterSpec::ConfigHelper

  before do
    given_a_configuration_of(:is_windows => false)
  end

  it "should return ipaddress6 information for Darwin" do
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Darwin')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["-a"]).
      returns(ifconfig_fixture('darwin_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:223:32ff:fed5:ee34"
  end

  it "should return ipaddress6 information for Linux" do
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["2>/dev/null"]).
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:febe:2201"
  end

  it "should return ipaddress6 information for Linux with recent net-tools" do
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["2>/dev/null"]).
      returns(ifconfig_fixture('ifconfig_net_tools_1.60.txt'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:febe:2201"
  end

  it "should return ipaddress6 with fe80 in any other octet than the first for Linux" do
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["2>/dev/null"]).
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces_and_fe80'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:fe80:2201"
  end

  it "should not return ipaddress6 link-local address for Linux" do
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["2>/dev/null"]).
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces_and_no_public_ipv6'))

    Facter.value(:ipaddress6).should be_false
  end

  it "should return ipaddress6 information for Solaris" do
    Facter::Core::Execution.stubs(:exec).with('uname -s').returns('SunOS')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/usr/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["-a"]).
      returns(ifconfig_fixture('sunos_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:203:baff:fe27:a7c"
  end

  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'
    require 'facter/util/ip/windows'
    require 'facter_spec/windows_network'

    include FacterSpec::WindowsNetwork

    before :each do
      Facter.fact(:kernel).stubs(:value).returns(:windows)
      Facter::Util::Registry.stubs(:hklm_read).returns(nic_bindings)
      given_a_configuration_of(:is_windows => true)
    end

    it "should do what when VPN is turned on?"

    context "when you have no active network adapter" do
      it "should return nil if there are no active (or any) network adapters" do
        Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).returns([])

        Facter.value(:ipaddress6).should == nil
      end
    end

    it "should return nil if the system doesn't have ipv6 installed", :if => Facter::Util::Config.is_windows? do
      Facter::Util::Resolution.any_instance.expects(:warn).never
      Facter::Util::Registry.stubs(:hklm_read).raises(Win32::Registry::Error, 2)

      Facter.value(:ipaddress6).should == nil
    end

    context "when you have one network adapter" do
      it "should return empty if ipv6 is not on" do
        nic = given_a_valid_windows_nic_with_ipv4_and_ipv6
        nic.expects(:IPAddress).returns([ipAddress1])
        Facter::Util::WMI.expects(:execquery).returns([nic])

        Facter.value(:ipaddress6).should == nil
      end

      it "should return the ipv6 address properly" do
        Facter::Util::WMI.expects(:execquery).returns([given_a_valid_windows_nic_with_ipv4_and_ipv6])

        Facter.value(:ipaddress6).should == ipv6Address0
      end

      it "should return the first ipv6 address if there is more than one (multi-homing)" do
        nic = given_a_valid_windows_nic_with_ipv4_and_ipv6
        nic.expects(:IPAddress).returns([ipAddress0, ipv6Address0,ipv6Address1])
        Facter::Util::WMI.expects(:execquery).returns([nic])

        Facter.value(:ipaddress6).should == ipv6Address0
      end

      it "should return return nil if the ipv6 address is link local" do
        nic = given_a_valid_windows_nic_with_ipv4_and_ipv6
        nic.expects(:IPAddress).returns([ipAddress0, ipv6LinkLocal])
        Facter::Util::WMI.expects(:execquery).returns([nic])

        Facter.value(:ipaddress6).should == nil
      end
    end

    context "when you have more than one network adapter" do
      it "should return empty if ipv6 is not on" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic0].expects(:IPAddress).returns([ipAddress0])
        nics[:nic1].expects(:IPAddress).returns([ipAddress1])
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:ipaddress6).should == nil
      end

      it "should return the ipv6 of the adapter with the lowest IP connection metric (best connection)" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic1].expects(:IPConnectionMetric).returns(5)
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:ipaddress6).should == ipv6Address1
      end

      it "should return the ipv6 of the adapter with the lowest IP connection metric (best connection) that has ipv6 enabled" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic1].expects(:IPConnectionMetric).returns(5)
        nics[:nic1].expects(:IPAddress).returns([ipAddress1])
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:ipaddress6).should == ipv6Address0
      end

      context "when the IP connection metric is the same" do
        it "should return the ipv6 of the adapter with the lowest binding order" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:ipaddress6).should == ipv6Address0
        end

        it "should return the ipv6 of the adapter with the lowest binding order even if the adapter is not first" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::Registry.stubs(:hklm_read).returns(["\\Device\\#{settingId1}", "\\Device\\#{settingId0}" ])
          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:ipaddress6).should == ipv6Address1
        end
      end
    end
  end
end
