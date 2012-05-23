#!/usr/bin/env rspec

require 'spec_helper'

def cpuinfo_fixture(filename)
  File.open(fixtures('cpuinfo', filename)).readlines
end

describe "Processor facts" do
  describe "on Windows" do
    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("windows")
    end

    def load(procs)
      require 'facter/util/wmi'
      Facter::Util::WMI.stubs(:execquery).with("select * from Win32_Processor").returns(procs)
      # This is to workaround #14674
      Facter.fact(:architecture).stubs(:value).returns("x64")

      # processor facts belong to a file with a different name,
      # so load the file explicitly (after stubbing kernel),
      # but we have to stub execquery first
      Facter.collection.loader.load(:processor)
    end

    describe "2003" do
      before :each do
        proc = stubs 'proc'
        proc.stubs(:NumberOfLogicalProcessors).raises(RuntimeError)
        proc.stubs(:Name).returns("Intel(R)    Celeron(R)   processor")

        load(Array.new(2, proc))
      end

      it "should count 2 processors" do
        Facter.fact(:processorcount).value.should == "2"
      end

      it "should squeeze the processor name 2 times" do
        2.times do |i|
          Facter.fact("processor#{i}".to_sym).value.should == "Intel(R) Celeron(R) processor"
        end
      end
    end

    describe "2008" do
      before :each do
        proc = stubs 'proc'
        proc.stubs(:NumberOfLogicalProcessors).returns(2)
        proc.stubs(:Name).returns("Intel(R)    Celeron(R)   processor")

        load(Array.new(2, proc))
      end

      it "should count 4 processors" do
        Facter.fact(:processorcount).value.should == "4"
      end

      it "should squeeze the processor name 4 times" do
        4.times do |i|
          Facter.fact("processor#{i}".to_sym).value.should == "Intel(R) Celeron(R) processor"
        end
      end
    end
  end

  describe "on Solaris" do
    before :each do
      Facter.collection.loader.load(:processor)
      Facter.fact(:kernel).stubs(:value).returns(:sunos)
    end

    it "should detect the correct processor count on x86_64" do
      fixture_data = File.read(fixtures('processorcount','solaris-x86_64-kstat-cpu-info'))
      Facter::Util::Resolution.expects(:exec).with("/usr/bin/kstat cpu_info").returns(fixture_data)
      Facter.fact(:processorcount).value.should == 8
    end

    it "should detect the correct processor count on sparc" do
      fixture_data = File.read(fixtures('processorcount','solaris-sparc-kstat-cpu-info'))
      Facter::Util::Resolution.expects(:exec).with("/usr/bin/kstat cpu_info").returns(fixture_data)
      Facter.fact(:processorcount).value.should == 8
    end
  end

  describe "on Unixes" do
    before :each do
      Facter.collection.loader.load(:processor)
    end

    it "should be 1 in SPARC fixture" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:operatingsystem).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("sparc")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("sparc"))

      Facter.fact(:processorcount).value.should == "1"
    end

    it "should be 2 in ppc64 fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("ppc64")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("ppc64"))

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 2 in panda-armel fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("arm")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("panda-armel"))

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 1 in bbg3-armel fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("arm")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("bbg3-armel"))

      Facter.fact(:processorcount).value.should == "1"
    end

    it "should be 1 in beaglexm-armel fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("arm")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("beaglexm-armel"))

      Facter.fact(:processorcount).value.should == "1"
    end

    it "should be 1 in amd64solo fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("amd64")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64solo"))

      Facter.fact(:processorcount).value.should == "1"
    end

    it "should be 2 in amd64dual fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("amd64")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64dual"))

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 3 in amd64tri fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("amd64")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64tri"))

      Facter.fact(:processorcount).value.should == "3"
    end

    it "should be 4 in amd64quad fixture on Linux" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      Facter.fact(:architecture).stubs(:value).returns("amd64")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64quad"))

      Facter.fact(:processorcount).value.should == "4"
    end

    it "should be 2 on dual-processor Darwin box" do
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      Facter::Util::Resolution.stubs(:exec).with("sysctl -n hw.ncpu").returns('2')

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 2 on dual-processor OpenBSD box" do
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      Facter::Util::Resolution.stubs(:exec).with("sysctl -n hw.ncpu").returns('2')

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 2 on dual-processor DragonFly box" do
      Facter.fact(:kernel).stubs(:value).returns("DragonFly")
      Facter::Util::Resolution.stubs(:exec).with("sysctl -n hw.ncpu").returns('2')

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 6 on six-processor AIX box" do
      Facter.fact(:kernel).stubs(:value).returns("AIX")
      Facter::Util::Resolution.stubs(:exec).with("lsdev -Cc processor").returns("proc0 Available 00-00 Processor\nproc2 Available 00-02 Processor\nproc4 Available 00-04 Processor\nproc6 Available 00-06 Processor\nproc8 Available 00-08 Processor\nproc10 Available 00-10 Processor")
      Facter::Util::Resolution.stubs(:exec).with("lsattr -El proc0 -a type").returns("type PowerPC_POWER3 Processor type False")

      Facter.fact(:processorcount).value.should == "6"
    end

    it "should be 2 via sysfs when cpu0 and cpu1 are present" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
      ## sysfs method is only used if cpuinfo method returned no processors
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns([])
      Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu[0-9]*").returns(%w{
        /sys/devices/system/cpu/cpu0
        /sys/devices/system/cpu/cpu1
      })

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should be 16 via sysfs when cpu0 through cpu15 are present" do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      File.stubs(:exists?).with('/sys/devices/system/cpu').returns(true)
      ## sysfs method is only used if cpuinfo method returned no processors
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      File.stubs(:readlines).with("/proc/cpuinfo").returns([])
      Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu[0-9]*").returns(%w{
        /sys/devices/system/cpu/cpu0
        /sys/devices/system/cpu/cpu1
        /sys/devices/system/cpu/cpu2
        /sys/devices/system/cpu/cpu3
        /sys/devices/system/cpu/cpu4
        /sys/devices/system/cpu/cpu5
        /sys/devices/system/cpu/cpu6
        /sys/devices/system/cpu/cpu7
        /sys/devices/system/cpu/cpu8
        /sys/devices/system/cpu/cpu9
        /sys/devices/system/cpu/cpu10
        /sys/devices/system/cpu/cpu11
        /sys/devices/system/cpu/cpu12
        /sys/devices/system/cpu/cpu13
        /sys/devices/system/cpu/cpu14
        /sys/devices/system/cpu/cpu15
      })

      Facter.fact(:processorcount).value.should == "16"
    end
  end
end
