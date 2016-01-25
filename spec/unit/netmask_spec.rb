#! /usr/bin/env ruby

require 'spec_helper'
require 'shared_formats/parses'
require 'facter/util/ip'

shared_examples_for "netmask from ifconfig output" do |platform, address, fixture|
  it "correctly on #{platform}" do
    Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read(fixture))
    Facter.collection.internal_loader.load(:netmask)

    Facter.fact(:netmask).value.should eq(address)
  end
end

describe "The netmask fact" do
  context "on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    example_behavior_for "netmask from ifconfig output",
      "Archlinux (net-tools 1.60)", "255.255.255.0",
      "ifconfig_net_tools_1.60.txt"
    example_behavior_for "netmask from ifconfig output",
      "Ubuntu 12.04", "255.255.255.255",
      "ifconfig_ubuntu_1204.txt"
  end

  context "on AIX" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("AIX")
    end

    example_behavior_for "netmask from ifconfig output",
      "AIX 7", "255.255.255.0",
      "ifconfig_aix_7.txt"

  end

  context "on Darwin" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
    end

    example_behavior_for "netmask from ifconfig output",
      "Darwin 10.8.5", "255.255.252.0", "darwin_10_8_5.txt"
  end

  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'
    require 'facter_spec/windows_network'

    include FacterSpec::WindowsNetwork

    before :each do
      Facter.fact(:kernel).stubs(:value).returns(:windows)
      Facter::Util::Registry.stubs(:hklm_read).returns(nic_bindings)
    end

    describe "when you have no active network adapter" do
      it "should return nil if there are no active (or any) network adapters" do
        Facter::Util::WMI.expects(:execquery).returns([])

        Facter.value(:netmask).should == nil
      end
    end

    describe "when you have one network adapter" do
      it "should return properly" do
        nic = given_a_valid_windows_nic_with_ipv4_and_ipv6
        Facter::Util::WMI.expects(:execquery).returns([nic])

        Facter.value(:netmask).should == subnet0
      end
    end

    describe "when you have more than one network adapter" do
      it "should return the netmask of the adapter with the lowest IP connection metric (best connection)" do
        nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
        nics[:nic1].expects(:IPConnectionMetric).returns(5)
        Facter::Util::WMI.expects(:execquery).returns(nics.values)

        Facter.value(:netmask).should == subnet1
      end

      context "when the IP connection metric is the same" do
        it "should return the netmask of the adapter with the lowest binding order" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)

          Facter.value(:netmask).should == subnet0
        end

        it "should return the netmask of the adapter with the lowest binding even if the adapter is not first" do
          nics = given_two_valid_windows_nics_with_ipv4_and_ipv6
          Facter::Util::WMI.expects(:execquery).returns(nics.values)
          Facter::Util::Registry.stubs(:hklm_read).returns(["\\Device\\#{settingId1}", "\\Device\\#{settingId0}" ])

          Facter.value(:netmask).should == subnet1
        end
      end
    end
  end
end
