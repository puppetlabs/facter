#! /usr/bin/env ruby

require 'spec_helper'
require 'shared_formats/parses'
require 'facter/util/ip'

shared_examples_for "interface netmask and mtu from ifconfig output" do |platform, interface, netmask, mtu, fixture|
  it "should be correct on #{platform} for interface #{interface}" do
    Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read(fixture))
    Facter::Util::IP.stubs(:get_output_for_interface_and_label).
      returns(my_fixture_read("#{fixture}.#{interface}"))
    Facter.collection.internal_loader.load(:interfaces)

    Facter.fact("netmask_#{interface}".intern).value.should eq(netmask)
    Facter.fact("mtu_#{interface}".intern).value.should eq(mtu)
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

  it "should properly format a mac address" do
    Facter::Util::IP.stubs(:get_interfaces).returns ["net0"]
    Facter::Util::IP.stubs(:get_interface_value).returns "0:12:34:56:78:90"

    Facter.collection.internal_loader.load(:interfaces)

    fact = Facter.fact("macaddress_net0".intern)
    fact.value.should eq("00:12:34:56:78:90")
  end
end

describe "Netmask and MTU handling on Linux" do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
  end

  example_behavior_for "interface netmask and mtu from ifconfig output",
    "Archlinux (net-tools 1.60)", "em1",
    "255.255.255.0", 1500, "ifconfig_net_tools_1.60.txt"
  example_behavior_for "interface netmask and mtu from ifconfig output",
    "Archlinux (net-tools 1.60)", "lo",
    "255.0.0.0", 16436, "ifconfig_net_tools_1.60.txt"
end
