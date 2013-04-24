#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

shared_examples_for "iface specific ifconfig output" do |platform, address, fixture|
  it "correctly on #{platform} for eth0" do
    Facter::Util::IP.stubs(:ifconfig_interface).returns(my_fixture_read(fixture))
    subject.value.should == address
  end
end

describe "Per Interface IP facts" do
  it "should replace the ':' in an interface list with '_'" do
    # So we look supported
    Facter.fact(:kernel).stubs(:value).returns("SunOS")

    Facter::Util::IP.stubs(:get_interfaces).returns %w{eth0:1 eth1:2}
    Facter.fact(:interfaces).value.should == %{eth0_1,eth1_2}
  end

  it "should replace non-alphanumerics in an interface list with '_'" do
    Facter.fact(:kernel).stubs(:value).returns("windows")

    Facter::Util::IP.stubs(:get_interfaces).returns ["Local Area Connection", "Loopback \"Pseudo-Interface\" (#1)"]
    Facter.fact(:interfaces).value.should == %{Local_Area_Connection,Loopback__Pseudo_Interface____1_}
  end
end


RSpec.configure do |config|
  config.alias_it_should_behave_like_to :example_behavior_for, "parses"
end


describe "the ipaddress_$iface fact" do
  subject do
    Facter.collection.internal_loader.load(:interfaces)
    Facter.fact(:ipaddress_eth0)
  end

  context "on Linux" do
    before :each do
      Facter::Util::IP.stubs(:get_interfaces).returns(["eth0"])
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end
    example_behavior_for "iface specific ifconfig output", "Fedora 18", "10.10.220.1", "eth0_net_tools_2.0.txt"

    example_behavior_for "iface specific ifconfig output", "net_tools 1.60", "10.10.220.210", "eth0_net_tools_1.60.txt"
  end
end

describe "the ipaddress6_$iface fact" do
  subject do
    Facter.collection.internal_loader.load(:interfaces)
    Facter.fact(:ipaddress6_eth0)
  end

  context "on Linux" do
    before :each do
      Facter::Util::IP.stubs(:get_interfaces).returns(["eth0"])
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end
    example_behavior_for "iface specific ifconfig output", "Fedora 18", "dead::21f:bcff:fe0d:5fb1", "eth0_net_tools_2.0.txt"

    example_behavior_for "iface specific ifconfig output", "net_tools 1.60", "dead::216:3eff:fe7d:ec7e", "eth0_net_tools_1.60.txt"
  end
end
