#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'


def ifconfig_fixture(filename)
  File.read(fixtures('ifconfig', filename))
end

def netsh_fixture(filename)
  File.read(fixtures('netsh', filename))
end

describe "macaddress fact" do
  include FacterSpec::ConfigHelper

  before do
    given_a_configuration_of(:is_windows => false)
  end

  describe "when run on Linux" do
    describe "with /sys available" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.fact(:operatingsystem).stubs(:value).returns("Linux")
      end

      it "should glob /sys/class/net" do
        Dir.expects(:glob).with('/sys/class/net/*').returns([ '/sys/class/net/eth0', '/sys/class/net/lo' ])
        File.stubs(:read).returns( "00:12:3f:be:22:01\n" )

        Facter.value(:macaddress)
      end

      it "should open the address file of the first interface" do
        Dir.stubs(:glob).returns([ '/sys/class/net/eth0', '/sys/class/net/lo' ])
        File.expects(:read).with('/sys/class/net/eth0/address').returns( "00:12:3f:be:22:01\n" )

        Facter.value(:macaddress)
      end


      it "should return the macaddress of the first interface" do
        Dir.stubs(:glob).returns( [ '/sys/class/net/eth0', '/sys/class/net/lo' ])
        File.stubs(:read).returns( "00:12:3f:be:22:01\n" )

        Facter.value(:macaddress).should == "00:12:3f:be:22:01"
      end
    end

    describe "without /sys available" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        Facter.fact(:operatingsystem).stubs(:value).returns("Linux")
        Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
        Dir.stubs(:glob).with('/sys/class/net/*').returns([])
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
  end

  describe "when run on BSD" do
    it "should return macaddress information" do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")
      Facter::Util::IP.stubs(:exec_ifconfig).
        returns(ifconfig_fixture('bsd_ifconfig_all_with_multiple_interfaces'))

      Facter.value(:macaddress).should == "00:0b:db:93:09:67"
    end
  end

end
