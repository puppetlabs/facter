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

  describe "for Solaris" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
    end

    it "should return correct version on Solaris 10" do
      Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('solaris_10'))
      Facter.fact(:zpool_version).value.should == "22"
    end

    it "should return correct version on Solaris 11" do
      Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(my_fixture_read('solaris_11'))
      Facter.fact(:zpool_version).value.should == "33"
    end

    it "should return nil if zpool is not available" do
      Facter::Util::Resolution.stubs(:exec).with("zpool upgrade -v").returns(nil)
      Facter.fact(:zpool_version).value.should == nil
    end
  end

  it "should not run on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:zpool_version).value.should == nil
  end
end
