#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/posix'

describe "Physical processor count facts" do

  describe "on linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
    end

    it "should return one physical CPU" do
      Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(["/sys/devices/system/cpu/cpu0/topology/physical_package_id"])
      Facter::Core::Execution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")

      Facter.fact(:physicalprocessorcount).value.should == "1"
    end

    it "should return four physical CPUs" do
      Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(%w{
        /sys/devices/system/cpu/cpu0/topology/physical_package_id
        /sys/devices/system/cpu/cpu1/topology/physical_package_id
        /sys/devices/system/cpu/cpu2/topology/physical_package_id
        /sys/devices/system/cpu/cpu3/topology/physical_package_id
      })

      Facter::Core::Execution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")
      Facter::Core::Execution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu1/topology/physical_package_id").returns("1")
      Facter::Core::Execution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu2/topology/physical_package_id").returns("2")
      Facter::Core::Execution.stubs(:exec).with("cat /sys/devices/system/cpu/cpu3/topology/physical_package_id").returns("3")

      Facter.fact(:physicalprocessorcount).value.should == "4"
    end
  end

  describe "on windows" do
    it "should return 4 physical CPUs" do
      Facter.fact(:kernel).stubs(:value).returns("windows")

      require 'facter/util/wmi'
      ole = stub 'WIN32OLE'
      Facter::Util::WMI.expects(:execquery).with("select Name from Win32_Processor").returns(ole)
      ole.stubs(:Count).returns(4)

      Facter.fact(:physicalprocessorcount).value.should == "4"
    end
  end

  describe "on solaris" do
    let(:psrinfo) do
      "0       on-line   since 10/16/2012 14:06:12\n" +
      "1       on-line   since 10/16/2012 14:06:14\n"
    end

    %w{ 5.8 5.9 5.10 5.11 }.each do |release|
      it "should use the output of psrinfo -p on #{release}" do
        Facter.fact(:kernel).stubs(:value).returns(:sunos)
        Facter.stubs(:value).with(:kernelrelease).returns(release)

        Facter::Core::Execution.expects(:exec).with("/usr/sbin/psrinfo -p").returns("1")
        Facter.fact(:physicalprocessorcount).value.should == "1"
      end
    end

    %w{ 5.5.1 5.6 5.7 }.each do |release|
      it "uses psrinfo with no -p for kernelrelease #{release}" do
        Facter.fact(:kernel).stubs(:value).returns(:sunos)
        Facter.stubs(:value).with(:kernelrelease).returns(release)

        Facter::Core::Execution.expects(:exec).with("/usr/sbin/psrinfo").returns(psrinfo)
        Facter.fact(:physicalprocessorcount).value.should == "2"
      end
    end
  end

  describe "on openbsd" do
    it "should return 4 physical CPUs" do
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      Facter::Util::POSIX.expects(:sysctl).with("hw.ncpufound").returns("4")
      Facter.fact(:physicalprocessorcount).value.should == "4"
    end
  end
end
