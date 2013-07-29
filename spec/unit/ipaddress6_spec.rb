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
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Darwin')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["-a"]).
      returns(ifconfig_fixture('darwin_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:223:32ff:fed5:ee34"
  end

  it "should return ipaddress6 information for Linux" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["2>/dev/null"]).
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:febe:2201"
  end

  it "should return ipaddress6 information for Linux with recent net-tools" do
      Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
      Facter::Util::IP.stubs(:exec_ifconfig).with(["2>/dev/null"]).
        returns(ifconfig_fixture('ifconfig_net_tools_1.60.txt'))

      Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:febe:2201"
    end

  it "should return ipaddress6 information for Solaris" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('SunOS')
    Facter::Util::IP.stubs(:get_ifconfig).returns("/usr/sbin/ifconfig")
    Facter::Util::IP.stubs(:exec_ifconfig).with(["-a"]).
      returns(ifconfig_fixture('sunos_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:203:baff:fe27:a7c"
  end

  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'
    require 'facter/util/ip/windows'

    let(:settingId0) { '{4AE6B55C-6DD6-427D-A5BB-13535D4BE926}' }
    let(:settingId1) { '{38762816-7957-42AC-8DAA-3B08D0C857C7}' }
    let(:nic_bindings) { ["\\Device\\#{settingId0}", "\\Device\\#{settingId1}" ] }

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

    context "when you have one network adapter" do
      it "should return empty if ipv6 is not on" do
        network1 = mock('network1', :IPAddress => ["12.123.12.12"])
        Facter::Util::WMI.expects(:execquery).returns([network1])

        Facter.value(:ipaddress6).should == nil
      end

      it "should return the ipv6 address properly" do
        network1 = mock('network1', :IPAddress => ["12.123.12.12", "2011:0:4137:9e76:2087:77a:53ef:7527"])
        Facter::Util::WMI.expects(:execquery).returns([network1])

        Facter.value(:ipaddress6).should == "2011:0:4137:9e76:2087:77a:53ef:7527"
      end

      it "should return the first ipv6 address if there is more than one (multi-homing)" do
        network1 = mock('network1', :IPAddress => ["12.123.12.12", "2013:0:4137:9e76:2087:77a:53ef:7527", "2011:0:4137:9e76:2087:77a:53ef:7527"])
        Facter::Util::WMI.expects(:execquery).returns([network1])

        Facter.value(:ipaddress6).should == "2013:0:4137:9e76:2087:77a:53ef:7527"
      end

      it "should return return nil if the ipv6 address is link local" do
        network1 = mock('network1', :IPAddress => ["12.123.12.12", "fe80::2db2:5b42:4e30:b508"])
        Facter::Util::WMI.expects(:execquery).returns([network1])

        Facter.value(:ipaddress6).should == nil
      end
    end

    context "when you have more than one network adapter" do
      it "should return empty if ipv6 is not on" do
        network1 = mock('network1')
        network1.expects(:SettingID).returns(settingId0)
        network1.expects(:IPConnectionMetric).returns(10)
        network1.expects(:IPAddress).returns(["12.123.12.12"])
        network2 = mock('network2')
        network2.expects(:SettingID).returns(settingId1)
        network2.expects(:IPConnectionMetric).returns(10)
        network2.expects(:IPAddress).returns(["12.123.12.13"])
        Facter::Util::WMI.expects(:execquery).returns([network1, network2])

        Facter.value(:ipaddress6).should == nil
      end

      it "should return the ipv6 of the adapter with the lowest IP connection metric (best connection)" do
        network1 = mock('network1')
        network1.expects(:IPConnectionMetric).returns(10)
        network2 = mock('network2')
        network2.expects(:IPConnectionMetric).returns(5)
        network2.expects(:IPAddress).returns(["12.123.12.13", "2013:0:4137:9e76:2087:77a:53ef:7527"])
        Facter::Util::WMI.expects(:execquery).returns([network1, network2])

        Facter.value(:ipaddress6).should == "2013:0:4137:9e76:2087:77a:53ef:7527"
      end

      it "should return the ipv6 of the adapter with the lowest IP connection metric (best connection) that has ipv6 enabled" do
        network1 = mock('network1')
        network1.expects(:IPConnectionMetric).returns(10)
        network1.expects(:IPAddress).returns(["12.123.12.12", "2011:0:4137:9e76:2087:77a:53ef:7527"])
        network2 = mock('network2')
        network2.expects(:IPConnectionMetric).returns(5)
        network2.expects(:IPAddress).returns(["12.123.12.13"])

        Facter::Util::WMI.expects(:execquery).returns([network2, network1])

        Facter.value(:ipaddress6).should == "2011:0:4137:9e76:2087:77a:53ef:7527"
      end

      context "when the IP connection metric is the same" do
        it "should return the ipv6 of the adapter with the lowest binding order" do
          network1 = mock('network1')
          network1.expects(:SettingID).returns(settingId0)
          network1.expects(:IPConnectionMetric).returns(5)
          network1.expects(:IPAddress).returns(["12.123.12.12", "2011:0:4137:9e76:2087:77a:53ef:7527"])
          network2 = mock('network2')
          network2.expects(:SettingID).returns(settingId1)
          network2.expects(:IPConnectionMetric).returns(5)
          #network2.expects(:IPAddress).returns(["12.123.12.13", "2013:0:4137:9e76:2087:77a:53ef:7527"])
          Facter::Util::WMI.expects(:execquery).returns([network1, network2])

          Facter.value(:ipaddress6).should == "2011:0:4137:9e76:2087:77a:53ef:7527"
        end

        it "should return the ipv6 of the adapter with the lowest binding order even if the adapter is not first" do
<<<<<<< HEAD
          network1 = mock('network1')
          network1.expects(:SettingID).returns(settingId1)
          network1.expects(:IPConnectionMetric).returns(5)
          network2 = mock('network2')
          network2.expects(:SettingID).returns(settingId0)
          network2.expects(:IPConnectionMetric).returns(5)
          network2.expects(:IPAddress).returns(["12.123.12.13", "2013:0:4137:9e76:2087:77a:53ef:7527"])
          Facter::Util::WMI.expects(:execquery).returns([network1, network2])

          Facter.value(:ipaddress6).should == "2013:0:4137:9e76:2087:77a:53ef:7527"
||||||| parent of 6541f09... maint: remove whitespace from netmask.rb, windows_network.rb, and ipaddress6_spec.rb
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::Registry.stubs(:hklm_read).returns(["\\Device\\#{settingId1}", "\\Device\\#{settingId0}" ])

          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:ipaddress6).should == ipv6Address1
=======
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::Registry.stubs(:hklm_read).returns(["\\Device\\#{settingId1}", "\\Device\\#{settingId0}" ])
          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:ipaddress6).should == ipv6Address1
>>>>>>> 6541f09... maint: remove whitespace from netmask.rb, windows_network.rb, and ipaddress6_spec.rb
        end
      end
    end
  end
end
