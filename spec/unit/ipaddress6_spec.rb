#! /usr/bin/env ruby -S rspec

require 'spec_helper'

def ifconfig_fixture(filename)
  File.read(fixtures('ifconfig', filename))
end

def netsh_fixture(filename)
  File.read(fixtures('netsh', filename))
end


describe "IPv6 address fact" do
  include FacterSpec::ConfigHelper

  before do
    given_a_configuration_of(:is_windows => false)
  end

  [:freebsd, :linux, :openbsd, :darwin, :"hp-ux", :"gnu/kfreebsd", :windows].each do |platform|
    it "should return ipddress for #{platform}" do
      Facter.fact(:kernel).stubs(:value).returns(platform)
      Facter::Util::IP.stubs(:ipaddress).with(nil).returns("2610:10:20:209:223:32ff:fed5:ee34")
      Facter.fact(:ipaddress).value.should == "2610:10:20:209:223:32ff:fed5:ee34"
    end
  end

end
