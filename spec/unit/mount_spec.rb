#!/usr/bin/env ruby

$basedir = File.expand_path(File.dirname(__FILE__) + '/..')
require File.join($basedir, 'spec_helper')

require 'facter'

describe "mounts and devices facts" do

  before do
    # We need these facts loaded, but they belong to a file with a
    # different name, so load the file explicitly.
    Facter.collection.loader.load(:mount)
  end

  after do
    Facter.clear
  end

  it "should be / and /dev/sda1 with a single entry in /proc/mounts" do
	Facter.fact(:kernel).stubs(:value).returns("Linux")
	Dir.stubs(:glob).with('/dev/*').returns(['/dev/sda1'])
	File.stubs(:exists?).with("/dev/sda1").returns(true)
	File.stubs(:blockdev?).with("/dev/sda1").returns(true)
	File.stubs(:symlink?).with("/dev/sda1").returns(false)
	devstub = stub(:rdev => 2049)
	File.stubs(:stat).with("/dev/sda1").returns(devstub)
	mountstub = stub(:dev => 2049)
	File.stubs(:stat).with("/").returns(mountstub)
    Facter::Util::Resolution.stubs(:exec).with("cat /proc/mounts 2> /dev/null").returns('/dev/sda1 / ext4 ro,relatime,errors=remount-ro,barrier=1,data=ordered 0 0')

    Facter.value(:mount_points).should == "/"
    Facter.value(:mount_devices).should == "/dev/sda1"
  end
end
