#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "Operating System fact" do

  before do
    Facter.clear
  end

  after do
    Facter.clear
  end

  it "should default to the kernel name" do
    Facter.fact(:kernel).stubs(:value).returns("Nutmeg")

    Facter.fact(:operatingsystem).value.should == "Nutmeg"
  end

  it "should be Solaris for SunOS" do
     Facter.fact(:kernel).stubs(:value).returns("SunOS")

     Facter.fact(:operatingsystem).value.should == "Solaris"
  end

  it "should be ESXi for VMkernel" do
     Facter.fact(:kernel).stubs(:value).returns("VMkernel")

     Facter.fact(:operatingsystem).value.should == "ESXi"
  end

  it "should identify Oracle VM as OVS" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.stubs(:value).with(:lsbdistid).returns(nil)
    FileTest.stubs(:exists?).returns false

    FileTest.expects(:exists?).with("/etc/ovs-release").returns true
    FileTest.expects(:exists?).with("/etc/enterprise-release").returns true

    Facter.fact(:operatingsystem).value.should == "OVS"
  end
   
  it "should identify VMWare ESX" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.stubs(:value).with(:lsbdistid).returns(nil)
    FileTest.stubs(:exists?).returns false

    FileTest.expects(:exists?).with("/etc/vmware-release").returns true

    Facter.fact(:operatingsystem).value.should == "VMWareESX"
  end

  it "should identify Alpine Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    
    FileTest.stubs(:exists?).returns false
    
    FileTest.expects(:exists?).with("/etc/alpine-release").returns true

    Facter.fact(:operatingsystem).value.should == "Alpine"
  end

  it "should identify Scientific Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    FileTest.stubs(:exists?).returns false

    FileTest.expects(:exists?).with("/etc/redhat-release").returns true
    File.expects(:read).with("/etc/redhat-release").returns("Scientific Linux SLC 5.7 (Boron)")
    Facter.fact(:operatingsystem).value.should == "Scientific"
  end

  it "should differentiate between Scientific Linux CERN and Scientific Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    FileTest.stubs(:exists?).returns false

    FileTest.expects(:exists?).with("/etc/redhat-release").returns true
    File.expects(:read).with("/etc/redhat-release").returns("Scientific Linux CERN SLC 5.7 (Boron)")
    Facter.fact(:operatingsystem).value.should == "SLC"
  end

  it "should identify Ascendos Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    FileTest.stubs(:exists?).returns false

    FileTest.expects(:exists?).with("/etc/redhat-release").returns true
    File.expects(:read).with("/etc/redhat-release").returns("Ascendos release 6.0 (Nameless)")
    Facter.fact(:operatingsystem).value.should == "Ascendos"
  end
end
