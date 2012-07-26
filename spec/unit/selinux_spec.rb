#!/usr/bin/env rspec

require 'spec_helper'

describe "SELinux facts" do


  after do
    Facter.clear
  end

  describe "should detect if SELinux is enabled" do
    it "and return true with default /selinux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")

      FileTest.stubs(:exists?).returns false
      File.stubs(:read).with("/proc/self/attr/current").returns("notkernel")

      FileTest.expects(:exists?).with("/selinux/enforce").returns true
      FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
      File.expects(:read).with("/proc/self/attr/current").returns("kernel")

      Facter.fact(:selinux).value.should == "true"
    end

    it "and return true with selinuxfs path from /proc" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")

      mounts = mock()
      lines = [ "selinuxfs /sys/fs/selinux selinuxfs rw,relatime 0 0" ]
      mounts.expects(:grep).multiple_yields(*lines)

      FileTest.expects(:exists?).with("/proc/self/mounts").returns true
      File.expects(:open).with("/proc/self/mounts").yields(mounts)

      FileTest.expects(:exists?).with("/sys/fs/selinux/enforce").returns true

      FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
      File.expects(:read).with("/proc/self/attr/current").returns("kernel")

      Facter.fact(:selinux).value.should == "true"
    end

    it "and return true with multiple selinuxfs mounts from /proc" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")

      mounts = mock()
      lines = [
        "selinuxfs /sys/fs/selinux selinuxfs rw,relatime 0 0",
        "selinuxfs /var/tmp/imgcreate-R2wmE6/install_root/sys/fs/selinux selinuxfs rw,relatime 0 0",
      ]
      mounts.expects(:grep).multiple_yields(*lines)

      FileTest.expects(:exists?).with("/proc/self/mounts").returns true
      File.expects(:open).with("/proc/self/mounts").yields(mounts)

      FileTest.expects(:exists?).with("/sys/fs/selinux/enforce").returns true

      FileTest.expects(:exists?).with("/proc/self/attr/current").returns true
      File.expects(:read).with("/proc/self/attr/current").returns("kernel")

      Facter.fact(:selinux).value.should == "true"
    end
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
    FileTest.stubs(:exists?).with("/proc/self/mounts").returns false

    File.expects(:read).with("/selinux/policyvers").returns("1")
    FileTest.expects(:exists?).with("/selinux/policyvers").returns true

    Facter.fact(:selinux_policyversion).value.should == "1"
  end

  it "it should return 'unknown' SELinux policy version if /selinux/policyvers doesn't exist" do
    Facter.fact(:selinux).stubs(:value).returns("true")
    FileTest.expects(:exists?).with("/proc/self/mounts").returns false
    FileTest.expects(:exists?).with("/selinux/policyvers").returns false

    Facter.fact(:selinux_policyversion).value.should == "unknown"
  end

  it "should return the SELinux current mode" do
    Facter.fact(:selinux).stubs(:value).returns("true")

    selinux_sestatus = my_fixture_read("selinux_sestatus")

    Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/sestatus').returns(selinux_sestatus)

    Facter.fact(:selinux_current_mode).value.should == "permissive"
  end

  it "should return the SELinux mode from the configuration file" do
    Facter.fact(:selinux).stubs(:value).returns("true")

    selinux_sestatus = my_fixture_read("selinux_sestatus")

    Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/sestatus').returns(selinux_sestatus)

    Facter.fact(:selinux_config_mode).value.should == "permissive"
  end

  it "should return the SELinux configuration file policy" do
    Facter.fact(:selinux).stubs(:value).returns("true")

    selinux_sestatus = my_fixture_read("selinux_sestatus")

    Facter::Util::Resolution.stubs(:exec).with('/usr/sbin/sestatus').returns(selinux_sestatus)

    Facter.fact(:selinux_config_policy).value.should == "targeted"
  end

  it "should ensure legacy selinux_mode facts returns same value as selinux_config_policy fact" do
    Facter.fact(:selinux).stubs(:value).returns("true")

    Facter.fact(:selinux_config_policy).stubs(:value).returns("targeted")

    Facter.fact(:selinux_mode).value.should == "targeted"
  end
end
