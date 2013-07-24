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

    let(:settingId0) { '{4AE6B55C-6DD6-427D-A5BB-13535D4BE926}' }
    let(:settingId1) { '{38762816-7957-42AC-8DAA-3B08D0C857C7}' }
    let(:nic_bindings) { ["\\Device\\#{settingId0}", "\\Device\\#{settingId1}" ] }

    before :each do
      Facter.fact(:kernel).stubs(:value).returns(:windows)
      Facter::Util::Registry.stubs(:hklm_read).returns(nic_bindings)
    end

    it "should do what when VPN is turned on?"

    context "when you have no active network adapter" do
      it "should return nil if there are no active (or any) network adapters" do
        Facter::Util::WMI.expects(:execquery).returns([])
        Facter::Util::Resolution.stubs(:exec)

        Facter.value(:ipaddress).should == nil
      end
    end

    context "when you have one network adapter" do
      it "should return the ip address properly" do
        network1 = mock('network1')
        network1.expects(:IPAddress).returns(["12.123.12.12", "2011:0:4137:9e76:2087:77a:53ef:7527"])
        Facter::Util::WMI.expects(:execquery).returns([network1])

        Facter.value(:ipaddress).should == "12.123.12.12"
      end
    end

    context "when you have more than one network adapter" do
      it "should return the ip of the adapter with the lowest IP connection metric (best connection)" do
        network1 = mock('network1')
        network1.expects(:IPConnectionMetric).returns(10)
        network2 = mock('network2')
        network2.expects(:IPConnectionMetric).returns(5)
        network2.expects(:IPAddress).returns(["12.123.12.13", "2013:0:4137:9e76:2087:77a:53ef:7527"])
        Facter::Util::WMI.expects(:execquery).returns([network1, network2])

        Facter.value(:ipaddress).should == "12.123.12.13"
      end

      it "should return the ip of the adapter with the lowest IP connection metric (best connection) that has ipv4 enabled" do
        network1 = mock('network1')
        network1.expects(:IPConnectionMetric).returns(10)
        network1.expects(:IPAddress).returns(["12.123.12.12", "2011:0:4137:9e76:2087:77a:53ef:7527"])
        network2 = mock('network2')
        network2.expects(:IPConnectionMetric).returns(5)
        network2.expects(:IPAddress).returns(["2013:0:4137:9e76:2087:77a:53ef:7527"])
        Facter::Util::WMI.expects(:execquery).returns([network1, network2])

        Facter.value(:ipaddress).should == "12.123.12.12"
      end

      context "when the IP connection metric is the same" do
        it "should return the ip of the adapter with the lowest binding order" do
          network1 = mock('network1')
          network1.expects(:SettingID).returns(settingId0)
          network1.expects(:IPConnectionMetric).returns(5)
          network1.expects(:IPAddress).returns(["12.123.12.12", "2011:0:4137:9e76:2087:77a:53ef:7527"])
          network2 = mock('network2')
          network2.expects(:SettingID).returns(settingId1)
          network2.expects(:IPConnectionMetric).returns(5)
          Facter::Util::WMI.expects(:execquery).returns([network1, network2])

          Facter.value(:ipaddress).should == "12.123.12.12"
        end

        it "should return the ip of the adapter with the lowest binding order even if the adapter is not first" do
          network1 = mock('network1')
          network1.expects(:IPConnectionMetric).returns(5)
          network1.expects(:SettingID).returns(settingId1)
          network2 = mock('network2')
          network2.expects(:IPConnectionMetric).returns(5)
          network2.expects(:IPAddress).returns(["12.123.12.13", "2013:0:4137:9e76:2087:77a:53ef:7527"])
          network2.expects(:SettingID).returns(settingId0)
          Facter::Util::WMI.expects(:execquery).returns([network1, network2])

          Facter.value(:ipaddress).should == "12.123.12.13"
        end
      end
    end
  end
end
