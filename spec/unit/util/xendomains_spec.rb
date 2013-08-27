#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/xendomains'

describe Facter::Util::Xendomains do
  describe ".get_domains" do

    describe "when xm list isn't executable and xl list is" do
      it "should return a list of running Xen Domains on Xen0" do
        xen0_domains = my_fixture_read("xendomains")
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
      end
    end

    describe "when xm list isn't executable and xl list is" do
      it "should return a list of running Xen Domains on Xen0" do
        xen0_domains = my_fixture_read("xendomains")
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(nil)
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
      end
    end

    describe "when xm list is executable and xl list isn't" do
      it "should return a list of running Xen Domains on Xen0" do
        xen0_domains = my_fixture_read("xendomains")
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(nil)
        Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
      end
    end

    describe "when xm list isn't executable and xl list isn't" do
      it "should be nil" do
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(nil)
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(nil)
        Facter::Util::Xendomains.get_domains.should == nil
      end
    end

  end
end
