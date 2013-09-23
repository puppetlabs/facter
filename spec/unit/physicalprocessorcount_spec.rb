#! /usr/bin/env ruby

require 'spec_helper'
require 'facter_spec/cpuinfo'
require 'facter/util/posix'

describe "Physical processor count facts" do

  describe "on linux" do
    include FacterSpec::Cpuinfo

    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end
    context "with /sys/devices/system/cpu and not /proc/cpuinfo" do
      before :each do
        File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
      end

      it "should return one physical CPU" do
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(["/sys/devices/system/cpu/cpu0/topology/physical_package_id"])
        File.stubs(:read).with("/sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")

        Facter.fact(:physicalprocessorcount).value.should == 1
      end

      it "should still return one physical CPU if on a multicore processor" do
        Dir.expects(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns([
          "/sys/devices/system/cpu/cpu0/topology/physical_package_id",
          "/sys/devices/system/cpu/cpu1/topology/physical_package_id",
          "/sys/devices/system/cpu/cpu2/topology/physical_package_id",
          "/sys/devices/system/cpu/cpu3/topology/physical_package_id"
        ])
        File.expects(:read).with("/sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")
        File.expects(:read).with("/sys/devices/system/cpu/cpu1/topology/physical_package_id").returns("0")
        File.expects(:read).with("/sys/devices/system/cpu/cpu2/topology/physical_package_id").returns("0")
        File.expects(:read).with("/sys/devices/system/cpu/cpu3/topology/physical_package_id").returns("0")

        Facter.fact(:physicalprocessorcount).value.should == 1
      end

      it "should return four physical CPUs" do
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(%w{
        /sys/devices/system/cpu/cpu0/topology/physical_package_id
        /sys/devices/system/cpu/cpu1/topology/physical_package_id
        /sys/devices/system/cpu/cpu2/topology/physical_package_id
        /sys/devices/system/cpu/cpu3/topology/physical_package_id
                                                                                                   })

        File.stubs(:read).with("/sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")
        File.stubs(:read).with("/sys/devices/system/cpu/cpu1/topology/physical_package_id").returns("1")
        File.stubs(:read).with("/sys/devices/system/cpu/cpu2/topology/physical_package_id").returns("2")
        File.stubs(:read).with("/sys/devices/system/cpu/cpu3/topology/physical_package_id").returns("3")

        Facter.fact(:physicalprocessorcount).value.should == 4
      end

      it "should return four physical CPUs if on 4 multicore processors" do
        Dir.expects(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(%w{
          /sys/devices/system/cpu/cpu0/topology/physical_package_id
          /sys/devices/system/cpu/cpu1/topology/physical_package_id
          /sys/devices/system/cpu/cpu2/topology/physical_package_id
          /sys/devices/system/cpu/cpu3/topology/physical_package_id
          /sys/devices/system/cpu/cpu4/topology/physical_package_id
          /sys/devices/system/cpu/cpu5/topology/physical_package_id
          /sys/devices/system/cpu/cpu6/topology/physical_package_id
          /sys/devices/system/cpu/cpu7/topology/physical_package_id
        })
        File.expects(:read).with("/sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")
        File.expects(:read).with("/sys/devices/system/cpu/cpu1/topology/physical_package_id").returns("0")
        File.expects(:read).with("/sys/devices/system/cpu/cpu2/topology/physical_package_id").returns("1")
        File.expects(:read).with("/sys/devices/system/cpu/cpu3/topology/physical_package_id").returns("1")
        File.expects(:read).with("/sys/devices/system/cpu/cpu4/topology/physical_package_id").returns("2")
        File.expects(:read).with("/sys/devices/system/cpu/cpu5/topology/physical_package_id").returns("2")
        File.expects(:read).with("/sys/devices/system/cpu/cpu6/topology/physical_package_id").returns("3")
        File.expects(:read).with("/sys/devices/system/cpu/cpu7/topology/physical_package_id").returns("3")

        Facter.fact(:physicalprocessorcount).value.should == 4
      end
    end

    context "with /proc/cpuinfo and not /sys/devices/system/cpu" do
      before :each do
        File.stubs(:exists?).with('/sys/devices/system/cpu').returns(false)
      end

      it "should return 1 physical CPU when there are multiple cores" do
        @cpuinfo = cpuinfo_fixture_read('amd64dual')
        File.stubs(:read).with("/proc/cpuinfo").returns(@cpuinfo)
        Facter.fact(:physicalprocessorcount).value.should == 1
      end

      it "should return 2 physical CPUs when there are 2 singlecore CPUs" do
        @cpuinfo = cpuinfo_fixture_read('two_singlecore')
        File.stubs(:read).with("/proc/cpuinfo").returns(@cpuinfo)
        Facter.fact(:physicalprocessorcount).value.should == 2
      end

      it "should return 2 physical CPUs when there are 2 multicore CPUs" do
        @cpuinfo = cpuinfo_fixture_read('two_multicore')
        File.stubs(:read).with("/proc/cpuinfo").returns(@cpuinfo)
        Facter.fact(:physicalprocessorcount).value.should == 2
      end

      it "should return 2 physical CPUs when there are 2 multicore CPUs" do
        @cpuinfo = cpuinfo_fixture_read('amd64twentyfour')
        File.stubs(:read).with("/proc/cpuinfo").returns(@cpuinfo)
        Facter.fact(:physicalprocessorcount).value.should == 2
      end
    end
  end

  describe "on windows" do
    it "should return 4 physical CPUs" do
      Facter.fact(:kernel).stubs(:value).returns("windows")
      Facter.fact(:kernelrelease).stubs(:value).returns("6.1.7601")

      require 'facter/util/wmi'
      ole = stub 'WIN32OLE'
      Facter::Util::WMI.expects(:execquery).with("select Name from Win32_Processor").returns(ole)
      ole.stubs(:Count).returns(4)

      Facter.fact(:physicalprocessorcount).value.should == 4
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

        Facter::Util::Resolution.expects(:exec).with("/usr/sbin/psrinfo -p").returns("1")
        Facter.fact(:physicalprocessorcount).value.should == "1"
      end
    end

    %w{ 5.5.1 5.6 5.7 }.each do |release|
      it "uses psrinfo with no -p for kernelrelease #{release}" do
        Facter.fact(:kernel).stubs(:value).returns(:sunos)
        Facter.stubs(:value).with(:kernelrelease).returns(release)

        Facter::Util::Resolution.expects(:exec).with("/usr/sbin/psrinfo").returns(psrinfo)
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
