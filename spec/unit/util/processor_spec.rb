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

  it "should get the processor type on a HP-UX box" do
    Facter.fact(:kernel).stubs(:value).returns("HP-UX")
    Facter::Util::Resolution.stubs(:exec).with("ioscan -fknCprocessor | grep processor").returns("processor   0  0/120     processor   CLAIMED     PROCESSOR    Processor\nprocessor   1  0/121     processor   CLAIMED     PROCESSOR    Processor\nprocessor   2  0/122     processor   CLAIMED     PROCESSOR    Processor\nprocessor   3  0/123     processor   CLAIMED     PROCESSOR    Processor\nprocessor   4  0/124     processor   CLAIMED     PROCESSOR    Processor\nprocessor   5  0/125     processor   CLAIMED     PROCESSOR    Processor\nprocessor   6  0/126     processor   CLAIMED     PROCESSOR    Processor\nprocessor   7  0/127     processor   CLAIMED     PROCESSOR    Processor\nprocessor   8  1/120     processor   CLAIMED     PROCESSOR    Processor\nprocessor   9  1/121     processor   CLAIMED     PROCESSOR    Processor\nprocessor  10  1/122     processor   CLAIMED     PROCESSOR    Processor\nprocessor  11  1/123     processor   CLAIMED     PROCESSOR    Processor\nprocessor  12  1/124     processor   CLAIMED     PROCESSOR    Processor\nprocessor  13  5/125     processor   CLAIMED     PROCESSOR    Processor\nprocessor  14  5/126     processor   CLAIMED     PROCESSOR    Processor\nprocessor  15  5/127     processor   CLAIMED     PROCESSOR    Processor\nprocessor  16  6/120     processor   CLAIMED     PROCESSOR    Processor\nprocessor  17  6/121     processor   CLAIMED     PROCESSOR    Processor\nprocessor  18  6/122     processor   CLAIMED     PROCESSOR    Processor\nprocessor  19  6/123     processor   CLAIMED     PROCESSOR    Processor\nprocessor  20  6/124     processor   CLAIMED     PROCESSOR    Processor\nprocessor  21  6/125     processor   CLAIMED     PROCESSOR    Processor\nprocessor  22  7/120     processor   CLAIMED     PROCESSOR    Processor\nprocessor  23  7/121     processor   CLAIMED     PROCESSOR    Processor")
    Facter::Util::Resolution.stubs(:exec).with("machinfo | grep Intel").returns(" 13 Intel(R) Itanium 2 9000 series processors (1.6 GHz, 18 MB)")
    Facter::Util::Resolution.stubs(:exec).with("uname -m").returns("ia64")

    Facter::Util::Processor.enum_ioscan[0].should == "Itanium 2 9000 series processors (1.6 GHz, 18 MB)"
  end

  it "should get the processor description on Solaris (x86)" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter.fact(:architecture).stubs(:value).returns("i86pc")
    Facter::Util::Resolution.stubs(:exec).with("/usr/bin/kstat cpu_info").returns(my_fixture_read("solaris-i86pc"))

    Facter::Util::Processor.enum_kstat[0].should == "Intel(r) Core(tm) i5 CPU       M 450  @ 2.40GHz"
  end

  it "should get the processor description on Solaris (SPARC64)" do
    Facter.fact(:kernel).stubs(:value).returns("SunOS")
    Facter.fact(:architecture).stubs(:value).returns("sun4u")
    Facter::Util::Resolution.stubs(:exec).with("/usr/bin/kstat cpu_info").returns(my_fixture_read("solaris-sun4u"))

    Facter::Util::Processor.enum_kstat[0].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[1].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[2].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[3].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[4].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[5].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[6].should == "SPARC64-VII"
    Facter::Util::Processor.enum_kstat[7].should == "SPARC64-VII"
  end
end
