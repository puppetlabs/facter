#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'facter'

describe "Physical processor count facts" do
    before do
        Facter.loadfacts
    end
    before do
        Facter.clear
    end
    it "should return one physical CPU" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(["/sys/devices/system/cpu/cpu0/topology/physical_package_id"])
        Facter::Util::Resolution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")

        Facter.fact(:physicalprocessorcount).value.should == 1
    end

    it "should return four physical CPUs" do
        Facter.fact(:kernel).stubs(:value).returns("Linux")
        File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
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

    it "should return 4 physical CPUs on Windows" do
        Facter.fact(:kernel).stubs(:value).returns("windows")

        require 'facter/util/wmi'
        ole = stub 'WIN32OLE'
        Facter::Util::WMI.expects(:execquery).with("select Name from Win32_Processor").returns(ole)
        ole.stubs(:Count).returns(4)

        Facter.fact(:physicalprocessorcount).value.should == 4
    end
end
