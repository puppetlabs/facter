#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/util/processor'

def cpuinfo_fixture(filename)
  File.open(fixtures('cpuinfo', filename)).readlines
end

describe Facter::Util::Processor do
  it "should get the processor description from the amd64solo fixture" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:architecture).stubs(:value).returns("amd64")
    File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
    File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64solo"))

    Facter::Util::Processor.enum_cpuinfo[0].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
  end

  it "should get the processor descriptions from the amd64dual fixture" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:architecture).stubs(:value).returns("amd64")
    File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
    File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64dual"))

    Facter::Util::Processor.enum_cpuinfo[0].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
    Facter::Util::Processor.enum_cpuinfo[1].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
  end

  it "should get the processor descriptions from the amd64tri fixture" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:architecture).stubs(:value).returns("amd64")
    File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
    File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64tri"))

    Facter::Util::Processor.enum_cpuinfo[0].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
    Facter::Util::Processor.enum_cpuinfo[1].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
    Facter::Util::Processor.enum_cpuinfo[2].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
  end

  it "should get the processor descriptions from the amd64quad fixture" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:architecture).stubs(:value).returns("amd64")
    File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
    File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture("amd64quad"))
    
    Facter::Util::Processor.enum_cpuinfo[0].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
    Facter::Util::Processor.enum_cpuinfo[1].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
    Facter::Util::Processor.enum_cpuinfo[2].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
    Facter::Util::Processor.enum_cpuinfo[3].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
  end

  it "should get the processor type on AIX box" do
    Facter.fact(:kernel).stubs(:value).returns("AIX")
    Facter::Util::Resolution.stubs(:exec).with("lsdev -Cc processor").returns("proc0 Available 00-00 Processor\nproc2 Available 00-02 Processor\nproc4 Available 00-04 Processor\nproc6 Available 00-06 Processor\nproc8 Available 00-08 Processor\nproc10 Available 00-10 Processor")
    Facter::Util::Resolution.stubs(:exec).with("lsattr -El proc0 -a type").returns("type PowerPC_POWER3 Processor type False")

    Facter::Util::Processor.enum_lsdev[0].should == "PowerPC_POWER3"
  end
end
