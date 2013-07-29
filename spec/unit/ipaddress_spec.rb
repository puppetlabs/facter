#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

shared_examples_for "ifconfig output" do |platform, address, fixture|
  it "correctly on #{platform}" do
    Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read(fixture))
    subject.value.should == address
  end
end

RSpec.configure do |config|
  config.alias_it_should_behave_like_to :example_behavior_for, "parses"
end

describe "The ipaddress fact" do
  subject do
    Facter.collection.internal_loader.load(:ipaddress)
    Facter.fact(:ipaddress)
  end
  context "on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    example_behavior_for "ifconfig output",
      "Ubuntu 12.04", "10.87.80.110", "ifconfig_ubuntu_1204.txt"
    example_behavior_for "ifconfig output",
      "Fedora 17", "131.252.209.153", "ifconfig_net_tools_1.60.txt"
    example_behavior_for "ifconfig output",
      "Linux with multiple loopback addresses",
      "10.0.222.20",
      "ifconfig_multiple_127_addresses.txt"
  end

  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'
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
        Facter::Util::Resolution.stubs(:exec)

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
