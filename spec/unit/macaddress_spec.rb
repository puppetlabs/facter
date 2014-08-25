#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'


def ifconfig_fixture(filename)
  File.read(fixtures('ifconfig', filename))
end

describe "macaddress fact" do
  include FacterSpec::ConfigHelper

  before do
    given_a_configuration_of(:is_windows => false)
  end

  describe "when run on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:operatingsystem).stubs(:value).returns("Linux")
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
    end

    it "should return the macaddress of the first interface" do
      Facter::Util::IP.stubs(:exec_ifconfig).with(["-a","2>/dev/null"]).
        returns(ifconfig_fixture('linux_ifconfig_all_with_multiple_interfaces'))

      Facter.value(:macaddress).should == "00:12:3f:be:22:01"
    end

    it "should return nil when no macaddress can be found" do
      Facter::Util::IP.stubs(:exec_ifconfig).with(["-a","2>/dev/null"]).
        returns(ifconfig_fixture('linux_ifconfig_no_mac'))

      proc { Facter.value(:macaddress) }.should_not raise_error
      Facter.value(:macaddress).should be_nil
    end

    # some interfaces dont have a real mac addresses (like venet inside a container)
    it "should return nil when no interface has a real macaddress" do
      Facter::Util::IP.stubs(:exec_ifconfig).with(["-a","2>/dev/null"]).
        returns(ifconfig_fixture('linux_ifconfig_venet'))

      proc { Facter.value(:macaddress) }.should_not raise_error
      Facter.value(:macaddress).should be_nil
    end
  end

  describe "when run on BSD" do
    it "should return macaddress information" do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      Facter.fact(:operatingsystem).stubs(:value).returns("FreeBSD")
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
      Facter::Util::IP.stubs(:exec_ifconfig).
        returns(ifconfig_fixture('bsd_ifconfig_all_with_multiple_interfaces'))

      Facter.value(:macaddress).should == "00:0b:db:93:09:67"
    end
  end

  describe "when run on OpenBSD with bridge(4) rules" do
    it "should return macaddress information" do
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      Facter.fact(:operatingsystem).stubs(:value).returns("OpenBSD")
      Facter.fact(:osfamily).stubs(:value).returns("OpenBSD")
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
      Facter::Util::IP.stubs(:exec_ifconfig).
        returns(ifconfig_fixture('openbsd_bridge_rules'))

      proc { Facter.value(:macaddress) }.should_not raise_error
      Facter.value(:macaddress).should be_nil
    end
  end

end
