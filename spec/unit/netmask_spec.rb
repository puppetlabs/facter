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

  context "on Windows" do
    require 'facter/util/wmi'
    require 'facter/util/registry'

    let(:settingId0) { '{4AE6B55C-6DD6-427D-A5BB-13535D4BE926}' }
    let(:settingId1) { '{38762816-7957-42AC-8DAA-3B08D0C857C7}' }
    let(:nic_bindings) { ["\\Device\\#{settingId0}", "\\Device\\#{settingId1}" ] }

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
        network1 = mock('network1')
        network1.expects(:IPSubnet).returns(["255.255.255.0", "48","2"])
        Facter::Util::WMI.expects(:execquery).returns([network1])

        Facter.value(:netmask).should == "255.255.255.0"
      end
    end

    describe "when you have more than one network adapter" do
      it "should return the netmask of the adapter with the lowest IP connection metric (best connection)" do
        network1 = mock('network1')
        network1.expects(:IPConnectionMetric).returns(10)
        network2 = mock('network2')
        network2.expects(:IPConnectionMetric).returns(5)
        network2.expects(:IPSubnet).returns(["255.255.0.0", "48","2"])
        Facter::Util::WMI.expects(:execquery).returns([network1, network2])

        Facter.value(:netmask).should == "255.255.0.0"
      end

      context "when the IP connection metric is the same" do
        it "should return the netmask of the adapter with the lowest binding order" do
          network1 = mock('network1')
          network1.expects(:SettingID).returns(settingId0)
          network1.expects(:IPConnectionMetric).returns(5)
          network1.expects(:IPSubnet).returns(["255.255.255.0", "48","64"])
          network2 = mock('network2')
          network2.expects(:SettingID).returns(settingId1)
          network2.expects(:IPConnectionMetric).returns(5)

          Facter::Util::WMI.expects(:execquery).returns([network1, network2])

          Facter.value(:netmask).should =="255.255.255.0"
        end

        it "should return the netmask of the adapter with the lowest binding even if the adapter is not first" do
          network1 = mock('network1')
          network1.expects(:SettingID).returns(settingId1)
          network1.expects(:IPConnectionMetric).returns(5)
          network2 = mock('network2')
          network2.expects(:SettingID).returns(settingId0)
          network2.expects(:IPConnectionMetric).returns(5)
          network2.expects(:IPSubnet).returns(["255.255.0.0", "48","2"])
          Facter::Util::WMI.expects(:execquery).returns([network1, network2])

          Facter.value(:netmask).should =="255.255.0.0"
        end
      end
    end
  end
end
