#! /usr/bin/env ruby

require 'spec_helper'
require 'facter_spec/cpuinfo'
require 'facter/util/processor'

describe Facter::Util::Processor do
  describe "on linux" do
    include FacterSpec::Cpuinfo

    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
    end

    describe "with architecture amd64" do
      before :each do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
      end

      it "should get the processor description from the amd64solo fixture" do
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64solo"))
        Facter::Util::Processor.enum_cpuinfo[0].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
      end

      it "should get the processor descriptions from the amd64dual fixture" do
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64dual"))

        Facter::Util::Processor.enum_cpuinfo[0].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
        Facter::Util::Processor.enum_cpuinfo[1].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
      end

      it "should get the processor descriptions from the amd64tri fixture" do
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64tri"))

        Facter::Util::Processor.enum_cpuinfo[0].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
        Facter::Util::Processor.enum_cpuinfo[1].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
        Facter::Util::Processor.enum_cpuinfo[2].should == "Intel(R) Core(TM)2 Duo CPU     P8700  @ 2.53GHz"
      end

      it "should get the processor descriptions from the amd64quad fixture" do
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64quad"))

        Facter::Util::Processor.enum_cpuinfo[0].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
        Facter::Util::Processor.enum_cpuinfo[1].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
        Facter::Util::Processor.enum_cpuinfo[2].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
        Facter::Util::Processor.enum_cpuinfo[3].should == "Quad-Core AMD Opteron(tm) Processor 2374 HE"
      end
    end

    describe "with architecture x86" do
      before :each do
        Facter.fact(:architecture).stubs(:value).returns("x86")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(my_fixture_read("x86-pentium2").lines)
      end

      subject { Facter::Util::Processor.enum_cpuinfo }

      it "should have the correct processor titles" do
        subject[0].should == "Pentium II (Deschutes)"
        subject[1].should == "Pentium II (Deschutes)"
      end
    end
  end

  describe "on Solaris" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
    end

    it "should get the processor description on Solaris (x86)" do
      Facter.fact(:architecture).stubs(:value).returns("i86pc")
      Facter::Util::Resolution.stubs(:exec).with("/usr/bin/kstat cpu_info").returns(my_fixture_read("solaris-i86pc"))

      Facter::Util::Processor.enum_kstat[0].should == "Intel(r) Core(tm) i5 CPU       M 450  @ 2.40GHz"
    end

    it "should get the processor description on Solaris (SPARC64)" do
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
end
