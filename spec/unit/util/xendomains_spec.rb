#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/xendomains'

describe Facter::Util::Xendomains do
  describe ".get_domains" do

    describe "when xl exists on system" do
      describe "when xm doesn't exists on system" do
        it "should return a list of running Xen Domains on Xen0" do
          xen0_domains = my_fixture_read("xendomains")
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns('/usr/sbin/xl')
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns(nil)

          Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
          Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(nil)
          Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
        end
      end
      describe "when xm exists on system too" do
        it "should return a list of running Xen Domains on Xen0" do
          xen0_domains = my_fixture_read("xendomains")
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns('/usr/sbin/xl')
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns('/usr/sbin/xl')

          Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
          Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(nil)
          Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
        end

        it "xl should be first element of xen_commands array" do
	  Facter::Util::Xendomains.instance_variable_get(:@xen_commands).first.should == '/usr/sbin/xl'
        end
      end
    end

    describe "when xl not exists on system and xm exists" do
      it "should return a list of running Xen Domains on Xen0" do
        xen0_domains = my_fixture_read("xendomains")
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns(nil)
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns('/usr/sbin/xm')

#        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(nil)
        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
      end
    end

    describe "when xm not exists on system and xl not exists on system either" do
      it "should be nil" do
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns(nil)
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns(nil)
#        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(nil)
#        Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(nil)
        Facter::Util::Xendomains.get_domains.should == nil
      end
    end

  end
end
