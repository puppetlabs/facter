#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "ipaddress fact" do
  [:freebsd, :linux, :openbsd, :darwin, :"hp-ux", :"gnu/kfreebsd", :windows].each do |platform|
    it "should return ipddress for #{platform}" do
      Facter.fact(:kernel).stubs(:value).returns(platform)
      Facter::Util::IP.stubs(:ipaddress).with(nil).returns("131.252.209.153")
      Facter.fact(:ipaddress).value.should == "131.252.209.153"
    end
  end

  [:netbsd, :sunos].each do |platform|
    it "should return ipddress for #{platform}" do
      Facter.fact(:kernel).stubs(:value).returns(platform)
      Facter::Util::IP.stubs(:ipaddress).with(nil, /^127\.|^0\.0\.0\.0/).returns("131.252.209.153")
      Facter.fact(:ipaddress).value.should == "131.252.209.153"
    end
  end

end
