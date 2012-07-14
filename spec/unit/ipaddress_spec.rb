#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "ipaddress fact" do

  describe "on linux" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    it "should return ipddress for linux with /sbin/ifconfig" do
      ifconfig = my_fixture_read("linux_ifconfig_all_with_multiple_interfaces")
      FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(true)
      FileTest.stubs(:exists?).with("/sbin/ip").returns(false)
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').returns(ifconfig)
      Facter.fact(:ipaddress).value.should == "131.252.209.153"
    end

    it "should return ipddress for linux with /sbin/ip" do
      ifconfig = my_fixture_read("linux_ip_show_addr")
      FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(false)
      FileTest.stubs(:exists?).with("/sbin/ip").returns(true)
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ip addr show').returns(ifconfig)
      Facter.fact(:ipaddress).value.should == "198.245.51.174"
    end
  end

  describe "on FreeBSD" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    end

    it "should return ipddress for freebsd with /sbin/ifconfig" do
      ifconfig = my_fixture_read("freebsd_ifconfig_with_jails")
      FileTest.stubs(:exists?).with("/sbin/ifconfig").returns(true)
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').returns(ifconfig)
      Facter.fact(:ipaddress).value.should == "192.168.1.7"
    end

  end
end
