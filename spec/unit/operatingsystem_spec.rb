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

    it "should identify Oracle VM as OVS" do

        Facter.fact(:kernel).stubs(:value).returns("Linux")
        FileTest.stubs(:exists?).returns false

        FileTest.expects(:exists?).with("/etc/ovs-release").returns true
        FileTest.expects(:exists?).with("/etc/enterprise-release").returns true

        Facter.fact(:operatingsystem).value.should == "OVS"
    end
end
