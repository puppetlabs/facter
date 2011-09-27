#!/usr/bin/env rspec

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Physical processor count facts" do

  describe "on linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
    end

    it "should return one physical CPU" do
      Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(["/sys/devices/system/cpu/cpu0/topology/physical_package_id"])
      Facter::Util::Resolution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")

      Facter.fact(:physicalprocessorcount).value.should == 1
    end

    it "should return four physical CPUs" do
      Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(%w{
        /sys/devices/system/cpu/cpu0/topology/physical_package_id
        /sys/devices/system/cpu/cpu1/topology/physical_package_id
        /sys/devices/system/cpu/cpu2/topology/physical_package_id
        /sys/devices/system/cpu/cpu3/topology/physical_package_id
      })

      Facter::Util::Resolution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")
      Facter::Util::Resolution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu1/topology/physical_package_id").returns("1")
      Facter::Util::Resolution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu2/topology/physical_package_id").returns("2")
      Facter::Util::Resolution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu3/topology/physical_package_id").returns("3")

      Facter.fact(:physicalprocessorcount).value.should == 4
    end
  end

  describe "on windows" do
    it "should return 4 physical CPUs" do
      Facter.fact(:kernel).stubs(:value).returns("windows")

      require 'facter/util/wmi'
      ole = stub 'WIN32OLE'
      Facter::Util::WMI.expects(:execquery).with("select Name from Win32_Processor").returns(ole)
      ole.stubs(:Count).returns(4)

      Facter.fact(:physicalprocessorcount).value.should == 4
    end
  end

  describe "on solaris" do
    it "should use the output of psrinfo" do
      Facter.fact(:kernel).stubs(:value).returns(:sunos)
      Facter::Util::Resolution.expects(:exec).with("/usr/sbin/psrinfo -p").returns(1)
      Facter.fact(:physicalprocessorcount).value.should == 1
    end
  end
end
