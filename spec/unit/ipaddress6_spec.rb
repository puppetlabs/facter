#!/usr/bin/env rspec

require 'spec_helper'

def ifconfig_fixture(filename)
  File.read(fixtures('ifconfig', filename))
end

def netsh_fixture(filename)
  File.read(fixtures('netsh', filename))
end

describe "IPv6 address fact" do
  before do
    Facter::Util::Config.stubs(:is_windows?).returns(false)
  end

  it "should return ipaddress6 information for Darwin" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Darwin')
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a').
      returns(ifconfig_fixture('darwin_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:223:32ff:fed5:ee34"
  end

  it "should return ipaddress6 information for Linux" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:212:3fff:febe:2201"
  end

  it "should return ipaddress6 information for Solaris" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('SunOS')
    Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/ifconfig -a').
      returns(ifconfig_fixture('sunos_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress6).should == "2610:10:20:209:203:baff:fe27:a7c"
  end

  it "should return ipaddress6 information for Windows" do
    ENV.stubs(:[]).with('SYSTEMROOT').returns('d:/windows')
    Facter::Util::Config.stubs(:is_windows?).returns(true)

    fixture = netsh_fixture('windows_netsh_addresses_with_multiple_interfaces')
    Facter::Util::Resolution.stubs(:exec).with('d:/windows/system32/netsh.exe interface ipv6 show address level=verbose').
      returns(fixture)

    Facter.value(:ipaddress6).should == "2001:0:4137:9e76:2087:77a:53ef:7527"
  end
end
