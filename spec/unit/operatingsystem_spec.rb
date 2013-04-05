#! /usr/bin/env ruby

require 'spec_helper'

describe "Operating System fact" do

  before :each do
    FileTest.stubs(:exists?).returns false
  end

  it "should default to the kernel name" do
    Facter.fact(:kernel).stubs(:value).returns("Nutmeg")

    Facter.fact(:operatingsystem).value.should == "Nutmeg"
  end
  it "should be ESXi for VMkernel" do
     Facter.fact(:kernel).stubs(:value).returns("VMkernel")

     Facter.fact(:operatingsystem).value.should == "ESXi"
  end

  describe "on Solaris variants" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
    end

    it "should be Nexenta if /etc/debian_version is present" do
      FileTest.expects(:exists?).with("/etc/debian_version").returns true
      Facter.fact(:operatingsystem).value.should == "Nexenta"
    end

    it "should be Solaris for SunOS if no other variants match" do
      Facter.fact(:operatingsystem).value.should == "Solaris"
    end
  end

  describe "on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")

      # Always stub lsbdistid by default, so tests work on Ubuntu
      Facter.stubs(:value).with(:lsbdistid).returns(nil)
    end

    {
      "Debian"      => "/etc/debian_version",
      "Gentoo"      => "/etc/gentoo-release",
      "Fedora"      => "/etc/fedora-release",
      "Mandriva"    => "/etc/mandriva-release",
      "Mandrake"    => "/etc/mandrake-release",
      "MeeGo"       => "/etc/meego-release",
      "Archlinux"   => "/etc/arch-release",
      "OracleLinux" => "/etc/oracle-release",
      "Alpine"      => "/etc/alpine-release",
      "VMWareESX"   => "/etc/vmware-release",
      "Bluewhite64" => "/etc/bluewhite64-version",
      "Slamd64"     => "/etc/slamd64-version",
      "Slackware"   => "/etc/slackware-version",
      "Amazon"      => "/etc/system-release",
    }.each_pair do |distribution, releasefile|
      it "should be #{distribution} if #{releasefile} exists" do
        FileTest.expects(:exists?).with(releasefile).returns true
        Facter.fact(:operatingsystem).value.should == distribution
      end
    end

    describe "depending on LSB release information" do
      before :each do
        Facter.collection.loader.load(:lsb)
      end

      it "on Ubuntu should use the lsbdistid fact" do
        FileUtils.stubs(:exists?).with("/etc/debian_version").returns true

        Facter.stubs(:value).with(:lsbdistid).returns("Ubuntu")
        Facter.fact(:operatingsystem).value.should == "Ubuntu"
      end

    end


    # Check distributions that rely on the contents of /etc/redhat-release
    {
      "RedHat"     => "Red Hat Enterprise Linux Server release 6.0 (Santiago)",
      "CentOS"     => "CentOS release 5.6 (Final)",
      "Scientific" => "Scientific Linux release 6.0 (Carbon)",
      "SLC"        => "Scientific Linux CERN SLC release 5.7 (Boron)",
      "Ascendos"   => "Ascendos release 6.0 (Nameless)",
      "CloudLinux" => "CloudLinux Server release 5.5",
      "XCP"        => "XCP release 1.6.10-61809c",
    }.each_pair do |operatingsystem, string|
      it "should be #{operatingsystem} based on /etc/redhat-release contents #{string}" do
        FileTest.expects(:exists?).with("/etc/redhat-release").returns true
        File.expects(:read).with("/etc/redhat-release").returns string

        Facter.fact(:operatingsystem).value.should == operatingsystem
      end
    end

    describe "Oracle variant" do
      it "should be OVS if /etc/ovs-release exists" do
        Facter.stubs(:value).with(:lsbdistid)
        FileTest.expects(:exists?).with("/etc/enterprise-release").returns true
        FileTest.expects(:exists?).with("/etc/ovs-release").returns true
        Facter.fact(:operatingsystem).value.should == "OVS"
      end

      it "should be OEL if /etc/ovs-release doesn't exist" do
        FileTest.expects(:exists?).with("/etc/enterprise-release").returns true
        FileTest.expects(:exists?).with("/etc/ovs-release").returns false
        Facter.fact(:operatingsystem).value.should == "OEL"
      end
    end

    it "should identify VMWare ESX" do
      Facter.stubs(:value).with(:lsbdistid).returns(nil)

      FileTest.expects(:exists?).with("/etc/vmware-release").returns true
      Facter.fact(:operatingsystem).value.should == "VMWareESX"
    end

    it "should differentiate between Scientific Linux CERN and Scientific Linux" do
      FileTest.expects(:exists?).with("/etc/redhat-release").returns true
      File.expects(:read).with("/etc/redhat-release").returns("Scientific Linux CERN SLC 5.7 (Boron)")
      Facter.fact(:operatingsystem).value.should == "SLC"
    end
  end
end
