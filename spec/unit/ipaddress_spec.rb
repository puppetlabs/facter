#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

shared_examples_for "ifconfig output" do |platform, address, fixture|
  it "correctly on #{platform}" do
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').returns(my_fixture_read(fixture))
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
end
