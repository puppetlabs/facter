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

describe "netmask fact" do
  before :each do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
  end

  context "on Linux" do
    example_behavior_for "netmask from ifconfig output",
      "Archlinux (net-tools 1.60)", "255.255.255.0",
      "ifconfig_net_tools_1.60.txt"
    example_behavior_for "netmask from ifconfig output",
      "Ubuntu 12.04", "255.255.255.255",
      "ifconfig_ubuntu_1204.txt"
  end
end
