#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

describe "ipaddress fact" do
  before do
    Facter.collection.internal_loader.load(:ipaddress)
  end

  context 'using `ifconfig`' do
    before :each do
      Facter.fact(:hostname).stubs(:value)
    end

    context "on Linux" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
      end

      def expect_ifconfig_parse(address, fixture)
        Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read(fixture))
        Facter.fact(:ipaddress).value.should == address
      end

      it "parses correctly on Ubuntu 12.04" do
        expect_ifconfig_parse "10.87.80.110", "ifconfig_ubuntu_1204.txt"
      end

      it "parses correctly on Fedora 17" do
        expect_ifconfig_parse "131.252.209.153", "ifconfig_net_tools_1.60.txt"
      end

      it "parses a real address over multiple loopback addresses" do
        expect_ifconfig_parse "10.0.222.20", "ifconfig_multiple_127_addresses.txt"
      end

      it "parses nothing with a non-english locale" do
        expect_ifconfig_parse nil, "ifconfig_non_english_locale.txt"
      end
    end
  end

  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'
    require 'facter/util/ip/windows'
    require 'facter_spec/windows_network'

    include FacterSpec::WindowsNetwork

    before :each do
      Facter.fact(:kernel).stubs(:value).returns(:windows)
      Facter.fact(:kernelrelease).stubs(:value).returns('6.1.7601')
      Facter::Util::Registry.stubs(:hklm_read).returns(nic_bindings)
    end

    it "should do what when VPN is turned on?"

    context "when you have no active network adapter" do
      it "should return nil if there are no active (or any) network adapters" do
        Facter::Util::WMI.expects(:execquery).with(Facter::Util::IP::Windows::WMI_IP_INFO_QUERY).returns([])
        Facter::Core::Execution.stubs(:execute)

        Facter.value(:ipaddress).should == nil
      end
    end

    context "when you have one network adapter" do
      it "should return the ip address properly" do
        nic = given_a_valid_windows_nic_with_ipv4_and_ipv6
        Facter::Util::WMI.expects(:execquery).returns([nic])

        Facter.value(:ipaddress).should == ipAddress0
      end
    end

    context "when you have more than one network adapter" do
      it "should return the ip of the adapter with the lowest IP connection metric (best connection)" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic1].expects(:IPConnectionMetric).returns(5)
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:ipaddress).should == ipAddress1
      end

      it "should return the ip of the adapter with the lowest IP connection metric (best connection) that has ipv4 enabled" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic1].expects(:IPConnectionMetric).returns(5)
        nics[:nic1].expects(:IPAddress).returns([ipv6Address1])
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:ipaddress).should == ipAddress0
      end

      context "when the IP connection metric is the same" do
        it "should return the ip of the adapter with the lowest binding order" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:ipaddress).should == ipAddress0
        end

        it "should return the ip of the adapter with the lowest binding order even if the adapter is not first" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)
          Facter::Util::Registry.stubs(:hklm_read).returns(["\\Device\\#{settingId1}", "\\Device\\#{settingId0}" ])

          Facter.value(:ipaddress).should == ipAddress1
        end
      end
    end
  end
end
