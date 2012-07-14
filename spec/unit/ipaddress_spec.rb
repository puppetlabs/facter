#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "ipaddress fact" do
  before { Facter.clear }
  after { Facter.clear }

  describe "on linux" do
    it "should return ipddress for linux with /sbin/ifconfig" do
      ifconfig = my_fixture_read("linux_ifconfig_all_with_multiple_interfaces")
      Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').returns(ifconfig)
      Facter.collection.internal_loader.load(:ipaddress)
      Facter.fact(:ipaddress).value.should == "131.252.209.153"
    end
  end

  describe "on linux" do
    it "should return ipddress for linux with /sbin/ip" do
      ifconfig = my_fixture_read("linux_ip_show_addr")
      Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
      #FileTest.expects(:exists?).with('/sbin/ifconfig').returns(false)
      FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(false)
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ip addr show').returns(ifconfig)
      Facter.collection.internal_loader.load(:ipaddress)
      Facter.fact(:ipaddress).value.should == "198.245.51.174"
    end
  end
end
