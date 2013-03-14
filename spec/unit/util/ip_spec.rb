#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/ip'

describe Facter::Util::IP do
  include FacterSpec::ConfigHelper

  %w{
    FreeBSD Linux NetBSD OpenBSD SunOS Darwin HP-UX GNU/kFreeBSD windows
    Dragonfly
  }.each do |platform|
    it "should be supported on #{platform}" do
      Facter::Util::IP.supported_platforms.should include platform
    end
  end

  describe "exec_ifconfig" do
    it "uses get_ifconfig" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig").once

      Facter::Util::IP.exec_ifconfig
    end
    it "support additional arguments" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")

      Facter::Util::Resolution.stubs(:exec).with("/sbin/ifconfig -a")

      Facter::Util::IP.exec_ifconfig(["-a"])
    end
    it "joins multiple arguments correctly" do
      Facter::Util::IP.stubs(:get_ifconfig).returns("/sbin/ifconfig")

      Facter::Util::Resolution.stubs(:exec).with("/sbin/ifconfig -a -e -i -j")

      Facter::Util::IP.exec_ifconfig(["-a","-e","-i","-j"])
    end
  end
end
