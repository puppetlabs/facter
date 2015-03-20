#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/xendomains'

describe Facter::Util::Xendomains do

  let(:xen0_domains) { my_fixture_read("xendomains") }

  describe "when the xen-toolstack command is present" do
    before do
      File.expects(:file?).with('/usr/lib/xen-common/bin/xen-toolstack').returns true
    end

    describe "and the xen-toolstack returns xl" do
      before do
        Facter::Util::Resolution.stubs(:exec).with('/usr/lib/xen-common/bin/xen-toolstack').returns('/usr/sbin/xl')
      end

      it "lists the domains running on Xen0 with the 'xl' command" do
        Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
      end

    end

    describe "and the xen-toolstack returns xm" do
      before do
        Facter::Util::Resolution.stubs(:exec).with('/usr/lib/xen-common/bin/xen-toolstack').returns('/usr/sbin/xm')
      end

      it "lists the domains running on Xen0 with the 'xm' command" do
        Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(xen0_domains)
        Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
      end

    end

    describe "and the xen-toolstack returns nil" do
      before do
        Facter::Util::Resolution.stubs(:exec).with('/usr/lib/xen-common/bin/xen-toolstack').returns(nil)
      end

      it "returns nil" do
        Facter::Util::Xendomains.get_domains.should == nil
      end

    end

  end

  describe "when the xen-toolstack command is not present" do
    before do
      File.expects(:file?).with('/usr/lib/xen-common/bin/xen-toolstack').returns false
    end

    describe "and the xl command is present" do
      before do
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns('/usr/sbin/xl')
      end

      describe "and the xm command is not present" do

        before do
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns(nil)
          Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xm list 2>/dev/null').never
        end

        it "lists the domains running on Xen0 with the 'xl' command" do
          Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
          Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
        end
      end

      describe "and the xm command is also present" do
        before do
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns('/usr/bin/xm')
          Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xm list 2>/dev/null').never
        end

        it "prefers xl over xm" do
          Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xl list 2>/dev/null').returns(xen0_domains)
          Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
        end
      end
    end

    describe "when xl is not present" do
      before do
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns(nil)
        Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xl list 2>/dev/null').never
      end

      describe "and the xm command is present" do
        before do
          Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns('/usr/sbin/xm')
        end

        it "lists the domains running on Xen0 with the 'xm' command" do
          Facter::Util::Resolution.expects(:exec).with('/usr/sbin/xm list 2>/dev/null').returns(xen0_domains)
          Facter::Util::Xendomains.get_domains.should == %{web01,mailserver}
        end
      end
    end

    describe "neither xl or xm are present" do
      it "returns nil" do
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xl').returns(nil)
        Facter::Util::Resolution.stubs(:which).with('/usr/sbin/xm').returns(nil)
        Facter::Util::Xendomains.get_domains.should == nil
      end
    end
  end
end
