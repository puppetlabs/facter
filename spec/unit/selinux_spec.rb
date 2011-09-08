#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "SELinux facts" do


    after do
        Facter.clear
    end

    it "should return true if SELinux enabled" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")

        FileTest.stubs(:exists?).returns false
        File.stubs(:read).with("/proc/self/attr/current").returns("notkernel")

        FileTest.expects(:exists?).with("/selinux/enforce").returns true
        FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
        File.expects(:read).with("/proc/self/attr/current").returns("kernel")

        Facter.fact(:selinux).value.should == "true"
    end

    it "should return true if SELinux policy enabled" do
       Facter.fact(:selinux).stubs(:value).returns("true")

       FileTest.stubs(:exists?).returns false
       File.stubs(:read).with("/selinux/enforce").returns("0")

       FileTest.expects(:exists?).with("/selinux/enforce").returns true
       File.expects(:read).with("/selinux/enforce").returns("1")

       Facter.fact(:selinux_enforced).value.should == "true"
    end

    it "should return an SELinux policy version" do
       Facter.fact(:selinux).stubs(:value).returns("true")
       FileTest.stubs(:exists?).with("/proc/self/mountinfo").returns false

       File.stubs(:read).with("/selinux/policyvers").returns("")

       File.expects(:read).with("/selinux/policyvers").returns("1")

       Facter.fact(:selinux_policyversion).value.should == "1"
    end

    it "should return the SELinux current mode" do
       Facter.fact(:selinux).stubs(:value).returns("true")

       sample_output_file = File.dirname(__FILE__) + '/data/selinux_sestatus'
       selinux_sestatus = File.read(sample_output_file)

       Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/sestatus').returns(selinux_sestatus)

       Facter.fact(:selinux_current_mode).value.should == "permissive"
    end

    it "should return the SELinux mode from the configuration file" do
       Facter.fact(:selinux).stubs(:value).returns("true")

       sample_output_file = File.dirname(__FILE__) + '/data/selinux_sestatus'
       selinux_sestatus = File.read(sample_output_file)

       Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/sestatus').returns(selinux_sestatus)

       Facter.fact(:selinux_config_mode).value.should == "permissive"
    end

    it "should return the SELinux configuration file policy" do
       Facter.fact(:selinux).stubs(:value).returns("true")

       sample_output_file = File.dirname(__FILE__) + '/data/selinux_sestatus'
       selinux_sestatus = File.read(sample_output_file)

       Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/sestatus').returns(selinux_sestatus)

       Facter.fact(:selinux_config_policy).value.should == "targeted"
    end

    it "should ensure legacy selinux_mode facts returns same value as selinux_config_policy fact" do
       Facter.fact(:selinux).stubs(:value).returns("true")

       Facter.fact(:selinux_config_policy).stubs(:value).returns("targeted")

       Facter.fact(:selinux_mode).value.should == "targeted"
    end
end
