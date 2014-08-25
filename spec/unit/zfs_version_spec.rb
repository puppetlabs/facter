#!/usr/bin/env ruby

require 'spec_helper'

describe "zfs_version fact" do

  # http://blogs.oracle.com/bobn/entry/live_upgrade_and_zfs_versioning
  #
  # Solaris Release ZPOOL Version ZFS Version
  # Solaris 10 10/08 (u6) 10  3
  # Solaris 10 5/09 (u7)  10  3
  # Solaris 10 10/09 (u8) 15  4
  # Solaris 10 9/10 (u9)  22  4
  # Solaris 10 8/11 (u10) 29  5
  # Solaris 11 11/11 (ga) 33  5

  before :each do
    Facter::Core::Execution.stubs(:which).with("zfs").returns("/usr/bin/zfs")
  end

  it "should return nil on old versions of Solaris 10" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_old'))
    Facter.fact(:zfs_version).value.should == nil
  end

  it "should return correct version on Solaris 10" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('solaris_10'))
    Facter.fact(:zfs_version).value.should == "3"
  end

  it "should return correct version on Solaris 11" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('solaris_11'))
    Facter.fact(:zfs_version).value.should == "5"
  end

  it "should return correct version on FreeBSD 8.2" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('freebsd_8.2'))
    Facter.fact(:zfs_version).value.should == "4"
  end

  it "should return correct version on FreeBSD 9.0" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('freebsd_9.0'))
    Facter.fact(:zfs_version).value.should == "5"
  end

  it "should return correct version on Linux with ZFS-fuse" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('linux-fuse_0.6.9'))
    Facter.fact(:zfs_version).value.should == "4"
  end

  it "should return correct version on Linux with zfsonlinux" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('zfsonlinux_0.6.1'))
    Facter.fact(:zfs_version).value.should == "5"
  end

  it "should return nil if zfs command is not available" do
    Facter::Core::Execution.stubs(:which).with("zfs").returns(nil)
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('linux-fuse_0.6.9'))
    Facter.fact(:zfs_version).value.should == nil
  end

  it "should return nil if zfs fails to run" do
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(nil)
    Facter.fact(:zfs_version).value.should == nil
  end

  it "handles the zfs command becoming available at a later point in time" do
    # Simulate Puppet configuring the zfs tools from a persistent daemon by
    # simulating three sequential responses to which('zfs').
    Facter::Core::Execution.stubs(:which).with("zfs").returns(nil,nil,"/usr/bin/zfs")
    Facter::Core::Execution.stubs(:exec).with("zfs -? 2> /dev/null").returns(my_fixture_read('zfs_new'))
    Facter::Core::Execution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('linux-fuse_0.6.9'))
    fact = Facter.fact(:zfs_version)

    # zfs is not present the first two times the fact is resolved.
    fact.value.should be_nil
    fact.value.should be_nil
    # zfs was configured between the second and third resolutions.
    fact.value.should == "4"
  end
end
