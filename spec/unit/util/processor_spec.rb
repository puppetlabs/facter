#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/util/processor'
require 'facter_spec/cpuinfo'

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
      Facter::Core::Execution.stubs(:exec).with("/usr/bin/kstat cpu_info").returns(my_fixture_read("solaris-i86pc"))

      Facter::Util::Processor.enum_kstat[0].should == "Intel(r) Core(tm) i5 CPU       M 450  @ 2.40GHz"
    end

    it "should get the processor description on Solaris (SPARC64)" do
      Facter.fact(:architecture).stubs(:value).returns("sun4u")
      Facter::Core::Execution.stubs(:exec).with("/usr/bin/kstat cpu_info").returns(my_fixture_read("solaris-sun4u"))

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

  describe "on AIX" do
    let(:lsattr) do
      "type PowerPC_POWER5 Processor type False\n"
    end

    def lsdev_examples
      examples = "proc0  Available 00-00 Processor\n" +
        "proc4  Available 00-04 Processor\n" +
        "proc8  Defined   00-08 Processor\n" +
        "proc12 Defined   00-12 Processor\n"
      examples
    end

    before :each do
      Facter.fact(:kernel).stubs(:value).returns("AIX")
      Facter::Util::Processor.stubs(:lsdev).returns(lsdev_examples)
      Facter::Util::Processor.stubs(:lsattr).returns(lsattr)
    end

    it "should create an array of processors" do
      Facter::Util::Processor.aix_processor_list[0].should eq "PowerPC_POWER5"
      Facter::Util::Processor.aix_processor_list[1].should eq "PowerPC_POWER5"
      Facter::Util::Processor.aix_processor_list[2].should eq "PowerPC_POWER5"
    end
  end

  describe "on HP-UX" do
    let(:ioscan) do
      "Class       I  H/W Path  Driver    S/W State H/W Type  Description\n" +
      "===================================================================\n" +
      "processor   0  0/120     processor CLAIMED   PROCESSOR Processor\n" +
      "processor   1  0/123     processor CLAIMED   PROCESSOR Processor\n"
    end

    describe "when machinfo is available" do
      def self.machinfo_examples
        examples = []
        examples << [File.read(fixtures('hpux','machinfo','ia64-rx2620')), "Intel(R) Itanium 2 processor"]
        examples << [File.read(fixtures('hpux','machinfo','ia64-rx6600')), "Intel(R) Itanium 2 9100 series processor (1.59 GHz, 18 MB)"]
        examples << [File.read(fixtures('hpux','machinfo','ia64-rx8640')), "Intel(R) Itanium 2 9100 series"]
        examples << [File.read(fixtures('hpux','machinfo','hppa-rp4440')), "PA-RISC 8800 processor (1000 MHz, 64 MB)"]
        examples << [File.read(fixtures('hpux','machinfo','superdome-server-SD32B')), "Intel(R) Itanium 2 9000 series"]
        examples << [File.read(fixtures('hpux','machinfo','superdome2-16s')), "Intel(R)  Itanium(R)  Processor 9340 (1.6 GHz, 15 MB)"]
        examples
      end

      machinfo_examples.each_with_index do |example, i|
        machinfo_example, expected_cpu = example
        context "machinfo example ##{i}" do
          before :each do
            Facter.fact(:kernel).stubs(:value).returns("HP-UX")
            Facter::Util::Processor.stubs(:ioscan).returns(ioscan)
            Facter::Util::Processor.stubs(:machinfo).returns(machinfo_example)
          end

          %w{ 0 1 }.each do |j|
            it "should find #{expected_cpu}" do
              Facter::Util::Processor.hpux_processor_list[j.to_i].should eq expected_cpu
            end
          end
        end
      end
    end

    describe "when machinfo is not available" do
      def self.model_and_getconf_examples
        examples = []
        examples << ["9000/800/L3000-5x",     "sched.models_present", "unistd.h_present", "532", "616",       "PA-RISC 8600 processor"]
        examples << ["9000/800/L3000-5x",     "",                     "unistd.h_present", "532", "616",       "HP PA-RISC2.0 CHIP TYPE #616"]
        examples << ["9000/800/L3000-5x",     "",                     "",                 "532", "616",       "CPU v532 CHIP TYPE #616"]
        examples << ["ia64 hp server rx2660", "sched.models_present", "unistd.h_present", "768", "536936708", "IA-64 archrev 0 CHIP TYPE #536936708"]
        examples << ["ia64 hp server rx2660", "",                     "unistd.h_present", "768", "536936708", "IA-64 archrev 0 CHIP TYPE #536936708"]
        examples << ["ia64 hp server rx2660", "",                     "",                 "768", "536936708", "CPU v768 CHIP TYPE #536936708"]
        examples
      end

      sched_models = File.readlines(fixtures('hpux','sched.models'))
      unistd_h     = File.readlines(fixtures('hpux','unistd.h'))
      model_and_getconf_examples.each_with_index do |example, i|
        model_example, sm, unistd, getconf_cpu_ver, getconf_chip_type, expected_cpu = example
        context "and model and getconf example ##{i}" do
          before :each do
            Facter.fact(:kernel).stubs(:value).returns("HP-UX")
            Facter::Util::Processor.stubs(:ioscan).returns(ioscan)
            Facter::Util::Processor.stubs(:getconf_cpu_version).returns(getconf_cpu_ver)
            Facter::Util::Processor.stubs(:getconf_cpu_chip_type).returns(getconf_chip_type)
            Facter::Util::Processor.stubs(:machinfo).returns(nil)
            Facter::Util::Processor.stubs(:model).returns(model_example)
          end

          if unistd == "unistd.h_present" then
            before :each do
              Facter::Util::Processor.stubs(:read_unistd_h).returns(unistd_h)
            end
          else
            before :each do
              Facter::Util::Processor.stubs(:read_unistd_h).returns(nil)
            end
          end

          if sm == "sched.models_present" then
            before :each do
              Facter::Util::Processor.stubs(:read_sched_models).returns(sched_models)
            end
          else
            before :each do
              Facter::Util::Processor.stubs(:read_sched_models).returns(nil)
            end
          end

          %w{ 0 1 }.each do |j|
            it "should find #{expected_cpu}" do
              Facter::Util::Processor.hpux_processor_list[j.to_i].should eq expected_cpu
            end
          end
        end
      end
    end
  end
end
