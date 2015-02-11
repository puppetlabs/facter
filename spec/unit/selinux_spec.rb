#! /usr/bin/env ruby

require 'spec_helper'

describe "SELinux facts" do
  describe "should detect if SELinux is enabled" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    it "and return true with default /selinux" do
      mounts_does_not_exist

      File.stubs(:read).with("/proc/self/attr/current").returns("notkernel")
      FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
      File.expects(:read).with("/proc/self/attr/current").returns("kernel")

      FileTest.expects(:exists?).with("/selinux/enforce").returns true

      Facter.fact(:selinux).value.should == true
    end

    it "and return true with selinuxfs path from /proc" do
      selinux_root = "/sys/fs/selinux"
      mounts_contains("selinuxfs #{selinux_root} selinuxfs rw,relatime 0 0")

      FileTest.expects(:exists?).with("#{selinux_root}/enforce").returns true

      FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
      File.expects(:read).with("/proc/self/attr/current").returns("kernel")

      Facter.fact(:selinux).value.should == true
    end

    it "and return true with multiple selinuxfs mounts from /proc" do
      selinux_root = "/sys/fs/selinux"
      mounts_contains(
        "selinuxfs #{selinux_root} selinuxfs rw,relatime 0 0",
        "selinuxfs /var/tmp/imgcreate-R2wmE6/install_root/sys/fs/selinux selinuxfs rw,relatime 0 0"
      )

      FileTest.expects(:exists?).with("#{selinux_root}/enforce").returns true

      FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
      File.expects(:read).with("/proc/self/attr/current").returns("kernel")

      Facter.fact(:selinux).value.should == true
    end
  end

  describe "when selinux is present" do
    before :each do
      Facter.fact(:selinux).stubs(:value).returns(true)
    end

    it "should return true if SELinux policy enabled" do
      mounts_does_not_exist

      FileTest.expects(:exists?).with("/selinux/enforce").returns true
      File.expects(:read).with("/selinux/enforce").returns("1")

      Facter.fact(:selinux_enforced).value.should == true
    end

    it "should return an SELinux policy version" do
      mounts_does_not_exist

      FileTest.expects(:exists?).with("/selinux/policyvers").returns true
      File.expects(:read).with("/selinux/policyvers").returns("1")

      Facter.fact(:selinux_policyversion).value.should == "1"
    end

    it "it should return 'unknown' SELinux policy version if /selinux/policyvers doesn't exist" do
      mounts_does_not_exist

      FileTest.expects(:exists?).with("/selinux/policyvers").returns false

      Facter.fact(:selinux_policyversion).value.should == "unknown"
    end

    it "should return the SELinux current mode" do
      sestatus_is(my_fixture_read("selinux_sestatus"))

      Facter.fact(:selinux_current_mode).value.should == "permissive"
    end

    it "should return the SELinux mode from the configuration file" do
      sestatus_is(my_fixture_read("selinux_sestatus"))

      Facter.fact(:selinux_config_mode).value.should == "permissive"
    end

    it "should return the SELinux configuration file policy" do
      sestatus_is(my_fixture_read("selinux_sestatus"))

      Facter.fact(:selinux_config_policy).value.should == "targeted"
    end
    it "should return the loaded SELinux policy" do
      sestatus_is(my_fixture_read("selinux_sestatus2"))

      Facter.fact(:selinux_config_policy).value.should == "default"
    end
  end

  def sestatus_is(status)
    Facter::Core::Execution.stubs(:exec).with('/usr/sbin/sestatus').returns(status)
  end

  def mounts_does_not_exist
    FileTest.stubs(:exists?).with("/proc/self/mounts").returns false
  end

  def mounts_contains(*lines)
    FileTest.expects(:exists?).with("/proc/self/mounts").returns true
    Facter::Core::Execution.expects(:exec).with("cat /proc/self/mounts").returns(lines.join("\n"))
  end

end
