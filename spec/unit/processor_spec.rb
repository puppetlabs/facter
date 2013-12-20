#! /usr/bin/env ruby

require 'facter/util/processor'
require 'spec_helper'
require 'facter_spec/cpuinfo'

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
      Facter.collection.internal_loader.load(:processor)
    end

    describe "2003" do
      before :each do
        proc = stubs 'proc'
        proc.stubs(:Name).returns("Intel(R)    Celeron(R)   processor")

        load(Array.new(2, proc))
      end

      it "should count 2 processors" do
        proc.expects(:NumberOfLogicalProcessors).never

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

  describe "on Linux" do
    include FacterSpec::Cpuinfo

    shared_context 'Linux processor stubs' do
      before :each do
        Facter.collection.internal_loader.load(:processor)

        Facter.fact(:kernel).stubs(:value).returns 'Linux'
        Facter.fact(:operatingsystem).stubs(:value).returns 'Linux'
        File.stubs(:exists?).with("/proc/cpuinfo").returns(true)
      end
    end

    shared_examples_for 'a /proc/cpuinfo based processor fact' do |processor_fact|
      include_context 'Linux processor stubs'

      it "should be 1 in SPARC fixture" do
        Facter.fact(:architecture).stubs(:value).returns("sparc")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("sparc"))

        Facter.fact(processor_fact).value.should == "1"
      end

      it "should be 2 in ppc64 fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("ppc64")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("ppc64"))

        Facter.fact(processor_fact).value.should == "2"
      end

      it "should be 2 in panda-armel fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("arm")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("panda-armel"))

        Facter.fact(processor_fact).value.should == "2"
      end

      it "should be 1 in bbg3-armel fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("arm")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("bbg3-armel"))

        Facter.fact(processor_fact).value.should == "1"
      end

      it "should be 1 in beaglexm-armel fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("arm")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("beaglexm-armel"))

        Facter.fact(processor_fact).value.should == "1"
      end

      it "should be 1 in amd64solo fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64solo"))

        Facter.fact(processor_fact).value.should == "1"
      end

      it "should be 2 in amd64dual fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64dual"))

        Facter.fact(processor_fact).value.should == "2"
      end

      it "should be 3 in amd64tri fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64tri"))

        Facter.fact(processor_fact).value.should == "3"
      end

      it "should be 4 in amd64quad fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.stubs(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64quad"))

        Facter.fact(processor_fact).value.should == "4"
      end
    end

    it_behaves_like 'a /proc/cpuinfo based processor fact', :processorcount

    def sysfs_cpu_stubs(count)
      (0...count).map { |index| "/sys/devices/system/cpu/cpu#{index}" }
    end

    describe 'when /proc/cpuinfo returns 0 processors (#2945)' do
      include_context 'Linux processor stubs'

      before do
        File.stubs(:readlines).with("/proc/cpuinfo").returns([])
        File.stubs(:exists?).with("/sys/devices/system/cpu").returns(true)
      end

      it "should be 2 via sysfs when cpu0 and cpu1 are present" do
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu[0-9]*").returns(
          sysfs_cpu_stubs(2)
        )

        Facter.fact(:processorcount).value.should == "2"
      end

      it "should be 16 via sysfs when cpu0 through cpu15 are present" do
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu[0-9]*").returns(
          sysfs_cpu_stubs(16)
        )

        Facter.fact(:processorcount).value.should == "16"
      end
    end
  end


  describe "on Unixes" do
    before :each do
      Facter.collection.internal_loader.load(:processor)
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

    it "should be 2 on dual-processor FreeBSD box" do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      Facter::Util::Resolution.stubs(:exec).with("sysctl -n hw.ncpu").returns('2')

      Facter.fact(:processorcount).value.should == "2"
    end

    it "should print the correct CPU Model on FreeBSD" do
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      Facter::Util::Resolution.stubs(:exec).with("sysctl -n hw.model").returns('SomeVendor CPU 3GHz')

      Facter.fact(:processor).value.should == "SomeVendor CPU 3GHz"
    end

    it "should be 2 on dual-processor DragonFly box" do
      Facter.fact(:kernel).stubs(:value).returns("DragonFly")
      Facter::Util::Resolution.stubs(:exec).with("sysctl -n hw.ncpu").returns('2')

      Facter.fact(:processorcount).value.should == "2"
    end
  end

  describe "on solaris" do
    before :each do
      Facter::Util::Processor.stubs(:kernel_fact_value).returns :sunos
      Facter.fact(:kernel).stubs(:value).returns(:sunos)
      Facter.collection.internal_loader.load(:processor)
    end

    before :all do
      @fixture_kstat_sparc  = File.read(fixtures('processorcount','solaris-sparc-kstat-cpu-info'))
      @fixture_kstat_x86_64 = File.read(fixtures('processorcount','solaris-x86_64-kstat-cpu-info'))
    end

    let(:kstat_sparc) { @fixture_kstat_sparc }
    let(:kstat_x86_64) { @fixture_kstat_x86_64 }

    %w{ 5.8 5.9 5.10 5.11 }.each do |release|
      %w{ sparc x86_64 }.each do |arch|
        it "uses kstat on release #{release} (#{arch})" do
          Facter.stubs(:value).with(:kernelrelease).returns(release)

          Facter::Util::Resolution.expects(:exec).with("/usr/sbin/psrinfo").never
          Facter::Util::Resolution.expects(:exec).with("/usr/bin/kstat cpu_info").returns(self.send("kstat_#{arch}".intern))
          Facter.fact(:processorcount).value.should == 8
        end
      end
    end

    %w{ 5.5.1 5.6 5.7 }.each do |release|
      it "uses psrinfo on release #{release}" do
        Facter.stubs(:value).with(:kernelrelease).returns(release)

        fixture_data = File.read(fixtures('processorcount','solaris-psrinfo'))
        Facter::Util::Resolution.expects(:exec).with("/usr/bin/kstat cpu_info").never
        Facter::Util::Resolution.expects(:exec).with("/usr/sbin/psrinfo").returns(fixture_data)
        Facter.fact(:processorcount).value.should == 24
      end
    end
  end
end

describe "processorX facts" do
  describe "on AIX" do
    def self.lsdev_examples
      examples = []
      examples << "proc0  Available 00-00 Processor\n" +
        "proc4  Available 00-04 Processor\n" +
        "proc8  Defined   00-08 Processor\n" +
        "proc12 Defined   00-12 Processor\n"
      examples
    end

    let(:lsattr) do
      "type PowerPC_POWER5 Processor type False\n"
    end

    lsdev_examples.each_with_index do |lsdev_example, i|
      context "lsdev example ##{i}" do
        before :each do
          Facter.fact(:kernel).stubs(:value).returns("AIX")
          Facter::Util::Processor.stubs(:lsdev).returns(lsdev_example)
          Facter::Util::Processor.stubs(:lsattr).returns(lsattr)
          Facter.collection.internal_loader.load(:processor)
        end

        lsdev_example.split("\n").each_with_index do |line, idx|
          aix_idx = idx * 4
          it "maps proc#{aix_idx} to processor#{idx} (#11609)" do
            Facter.value("processor#{idx}".to_sym).should == "PowerPC_POWER5"
          end
        end
      end
    end
  end

  describe "on HP-UX" do
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

    let(:ioscan) do
      "Class       I  H/W Path  Driver    S/W State H/W Type  Description\n" +
      "===================================================================\n" +
      "processor   0  0/120     processor CLAIMED   PROCESSOR Processor\n" +
      "processor   1  0/123     processor CLAIMED   PROCESSOR Processor\n"
    end

    describe "when machinfo is available" do
      machinfo_examples.each_with_index do |example, i|
        machinfo_example, expected_cpu = example
        context "machinfo example ##{i}" do
          before :each do
            Facter.fact(:kernel).stubs(:value).returns("HP-UX")
            Facter::Util::Processor.stubs(:ioscan).returns(ioscan)
            Facter::Util::Processor.stubs(:machinfo).returns(machinfo_example)
            Facter.collection.internal_loader.load(:processor)
          end

          %w{ 0 1 }.each do |j|
            it "should find #{expected_cpu}" do
              Facter.value("processor#{j}".to_sym).should == expected_cpu
            end
          end
        end
      end
    end

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

    describe "when machinfo is not available" do
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
              Facter.collection.internal_loader.load(:processor)
            end
          else
            before :each do
              Facter::Util::Processor.stubs(:read_sched_models).returns(nil)
              Facter.collection.internal_loader.load(:processor)
            end
          end

          %w{ 0 1 }.each do |j|
            it "should find #{expected_cpu}" do
              Facter.value("processor#{j}".to_sym).should == expected_cpu
            end
          end
        end
      end
    end
  end
end
