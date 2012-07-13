#!/usr/bin/env rspec

require 'spec_helper'

describe "ipaddress fact" do

  describe "on linux" do
    it "should return ipddress for linux with /sbin/ifconfig" do
      ifconfig = my_fixture_read("linux_ifconfig_all_with_multiple_interfaces")
      Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').returns(ifconfig)

      Facter.value(:ipaddress).should == "131.252.209.153"
    end
  end
end
