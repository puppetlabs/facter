#!/usr/bin/env ruby

require 'spec_helper'

describe "zpool_version fact" do

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
    Facter::Util::Resolution.stubs(:which).with("zpool").returns("/usr/bin/zpool")
  end

  it "should return correct version on Solaris 10" do
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('solaris_10'))
    Facter.fact(:zpool_version).value.should == "22"
  end

  it "should return correct version on Solaris 11" do
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('solaris_11'))
    Facter.fact(:zpool_version).value.should == "33"
  end

  it "should return correct version on FreeBSD 8.2" do
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('freebsd_8.2'))
    Facter.fact(:zpool_version).value.should == "15"
  end

  it "should return correct version on FreeBSD 9.0" do
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('freebsd_9.0'))
    Facter.fact(:zpool_version).value.should == "28"
  end

  it "should return correct version on Linux with ZFS-fuse" do
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('linux-fuse_0.6.9'))
    Facter.fact(:zpool_version).value.should == "23"
  end

  it "should return nil if zpool is not available" do
    Facter::Util::Resolution.stubs(:which).with("zpool").returns(nil)
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('linux-fuse_0.6.9'))
    Facter.fact(:zpool_version).value.should == nil
  end

  it "should return nil if zpool fails to run" do
    Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(nil)
    Facter.fact(:zpool_version).value.should == nil
  end

  it "handles the zpool command becoming available" do
    # Simulate Puppet configuring the zfs tools from a persistent daemon by
    # simulating three sequential responses to which('zpool')
    # (NOTE, each resolution causes which to execute twice.
    Facter::Util::Resolution.stubs(:which).
      with("zpool").
      returns(nil,nil,nil,nil,"/usr/bin/zpool")
    Facter::Util::Resolution.stubs(:exec).
      with("zpool upgrade -v").
      returns(my_fixture_read('linux-fuse_0.6.9'))

    fact = Facter.fact(:zpool_version)

    # zfs is not present the first two times the fact is resolved.
    fact.value.should_not == "23"
    fact.value.should_not == "23"
    # zfs was configured between the second and third resolutions.
    fact.value.should == "23"
  end
end
