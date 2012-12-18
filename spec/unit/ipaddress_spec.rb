#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

shared_examples_for "ifconfig output" do |platform, address, fixture|
  it "correctly on #{platform}" do
    Facter::Util::IP.stubs(:get_ifconfig).returns(my_fixture_read(fixture))
    subject.value.should == address
  end
end

RSpec.configure do |config|
  config.alias_it_should_behave_like_to :example_behavior_for, "parses"
end

describe "The ipaddress fact" do
  subject do
    Facter.collection.loader.load(:ipaddress)
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
  end
end
