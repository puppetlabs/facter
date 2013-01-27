#! /usr/bin/env ruby

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
    FileTest.stubs(:exists?).with('/sbin/ip').returns(false)
    FileTest.stubs(:exists?).with('/sbin/ifconfig').returns(true)
    FileTest.stubs(:exists?).with('/usr/sbin/ifconfig').returns(true)
  end

  it "should return ipaddress6 information for Darwin" do
    Facter.fact(:kernel).stubs(:value).returns(:darwin)
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').
      returns(ifconfig_fixture('darwin_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:223:32ff:fed5:ee34"
  end

  it "should return ipaddress6 information for Linux" do
    Facter.fact(:kernel).stubs(:value).returns(:linux)
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:febe:2201"
  end

  it "should return ipaddress6 information for Solaris" do
    Facter.fact(:kernel).stubs(:value).returns(:sunos)
    Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/ifconfig').
      returns(ifconfig_fixture('sunos_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:203:baff:fe27:a7c"
  end

  it "should return ipaddress6 information for Windows" do
    Facter.fact(:kernel).stubs(:value).returns(:windows)
    given_a_configuration_of(:is_windows => true)
    FileTest.stubs(:exists?).with('/system32/netsh.exe').returns(true)

    fixture = netsh_fixture('windows_netsh_addresses_with_multiple_interfaces')
    Facter::Util::Resolution.stubs(:exec).with('/system32/netsh.exe interface ipv6 show interface').
      returns(fixture)

    Facter.value(:ipaddress6).should == "2001:0:4137:9e76:2087:77a:53ef:7527"
  end
end
