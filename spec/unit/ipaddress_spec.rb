#! /usr/bin/env ruby

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

  it "should return ipaddress information for Darwin" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Darwin')
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a').
      returns(ifconfig_fixture('darwin_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress).should == "131.252.209.140"
  end

  it "should return ipaddress information for Linux" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a 2>/dev/null').
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress).should == "131.252.209.153"
  end 

  it "should return ipaddress information for Linux when net-tools >= 1.60" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a 2>/dev/null').
      returns(ifconfig_fixture('linux_ifconfig_no_addr'))

    Facter.value(:ipaddress).should == "131.252.209.153"
  end

  it "should return ipaddress information for Linux" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('Linux')
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig 2>/dev/null').
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress).should == "131.252.209.153"
  end

  it "should return ipaddress information for Solaris" do
    Facter::Util::Resolution.stubs(:exec).with('uname -s').returns('SunOS')
    Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/ifconfig -a').
      returns(ifconfig_fixture('sunos_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:ipaddress).should == "131.252.209.59"
  end

end
