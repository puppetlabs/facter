#!/usr/bin/env rspec

require 'spec_helper'

def ip_fixture(filename)
  File.read(fixtures('ip', filename))
end

describe "IPv4 address fact" do

  it "should return the first non 127.0.0.0/8 subnetted ip address for Linux" do
    Facter.fact(:kernel).stubs(:value).returns('Linux')
    Facter::Util::Resolution.stubs(:exec).with('ip addr').
      returns(ip_fixture('linux_ip_addr_ipv4_with_multiple_interfaces'))

    Facter.value(:ipaddress).should == "10.32.1.26"
  end
end