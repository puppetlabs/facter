#!/usr/bin/env rspec

require 'spec_helper'

def ifconfig_fixture(filename)
  File.read(fixtures('ifconfig', filename))
end

describe "ipaddress fact" do

  describe "on linux" do
    it "should return ipddress for linux with /sbin/ifconfig" do
      Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').
        returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

      Facter.value(:ipaddress).should == "131.252.209.153"
    end
  end
end
