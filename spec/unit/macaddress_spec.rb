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

  describe "when run on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:operatingsystem).stubs(:value).returns("Linux")
    end

    it "should return the macaddress of the first interface" do
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a').
        returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

      Facter.value(:macaddress).should == "00:12:3f:be:22:01"
    end

    it "should return nil when no macaddress can be found" do
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a').
        returns(ifconfig_fixture('linux_ifconfig_no_mac'))

      proc { Facter.value(:macaddress) }.should_not raise_error
      Facter.value(:macaddress).should be_nil
    end

    # some interfaces dont have a real mac addresses (like venet inside a container)
    it "should return nil when no interface has a real macaddress" do
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig -a').
        returns(ifconfig_fixture('linux_ifconfig_venet'))

      proc { Facter.value(:macaddress) }.should_not raise_error
      Facter.value(:macaddress).should be_nil
    end
  end

  describe "when run on BSD" do
    it "should return macaddress information" do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      Facter::Util::Resolution.stubs(:exec).with('/sbin/ifconfig').
        returns(ifconfig_fixture('bsd_ifconfig_all_with_multiple_interfaces'))

      Facter.value(:macaddress).should == "00:0b:db:93:09:67"
    end
  end

end
