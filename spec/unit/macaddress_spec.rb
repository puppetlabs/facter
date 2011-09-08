#!/usr/bin/env ruby

$basedir = File.expand_path(File.dirname(__FILE__) + '/..')
require File.join($basedir, 'spec_helper')

require 'facter'

def ifconfig_fixture(filename)
  ifconfig = File.new(File.join($basedir, 'fixtures', 'ifconfig', filename)).read
end

def netsh_fixture(filename)
  ifconfig = File.new(File.join($basedir, 'fixtures', 'netsh', filename)).read
end

describe "macaddress fact" do
  before do
    Facter::Util::Config.stubs(:is_windows?).returns(false)
  end

  it "should return macaddress information for Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:operatingsystem).stubs(:value).returns("Linux")
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a').
      returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:macaddress).should == "00:12:3f:be:22:01"
  end

  it "should return macaddress information for BSD" do
    Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
    Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').
      returns(ifconfig_fixture('bsd_ifconfig_all_with_multiple_interfaces'))

    Facter.value(:macaddress).should == "00:0b:db:93:09:67"
  end

end
