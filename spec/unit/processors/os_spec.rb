require 'spec_helper'
require 'facter/processors/os'
require 'facter/util/wmi'
require 'facter_spec/cpuinfo'

shared_context "processor list" do
  let(:proc_list_array) { ["Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz", "Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz"] }
end

describe Facter::Processor::Linux do
  include FacterSpec::Cpuinfo
  subject { described_class.new }
  include_context "processor list"
  describe "getting the processor list" do
    it "should delegate to the enum_cpuinfo utility" do
      Facter::Processor::Util.expects(:enum_cpuinfo).once.returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    describe "when enum_cpuinfo is available" do

      before :each do
        File.expects(:exists?).with("/proc/cpuinfo").returns(true)
      end

      it "should be 1 in SPARC fixture" do
        Facter.fact(:architecture).stubs(:value).returns("sparc")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("sparc"))
        count = subject.get_processor_count
        expect(count).to eq "1"
      end

      it "should be 2 in ppc64 fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("ppc64")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("ppc64"))
        count = subject.get_processor_count
        expect(count).to eq "2"
      end

      it "should be 2 in panda-armel fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("arm")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("panda-armel"))
        count = subject.get_processor_count
        expect(count).to eq "2"
      end

      it "should be 1 in bbg3-armel fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("arm")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("bbg3-armel"))
        count = subject.get_processor_count
        expect(count).to eq "1"
      end

      it "should be 1 in beaglexm-armel fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("arm")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("beaglexm-armel"))
        count = subject.get_processor_count
        expect(count).to eq "1"
      end

      it "should be 1 in amd64solo fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64solo"))
        count = subject.get_processor_count
        expect(count).to eq "1"
      end

      it "should be 2 in amd64dual fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64dual"))
        count = subject.get_processor_count
        expect(count).to eq "2"
      end

      it "should be 3 in amd64tri fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64tri"))
        count = subject.get_processor_count
        expect(count).to eq "3"
      end

      it "should be 4 in amd64quad fixture on Linux" do
        Facter.fact(:architecture).stubs(:value).returns("amd64")
        File.expects(:readlines).with("/proc/cpuinfo").returns(cpuinfo_fixture_readlines("amd64quad"))
        count = subject.get_processor_count
        expect(count).to eq "4"
      end
    end

    describe "when enum_cpuinfo returns 0 processors (#2945)" do

      def sysfs_cpu_stubs(count)
        (0...count).map { |index| "/sys/devices/system/cpu/cpu#{index}" }
      end

      before :each do
        subject.expects(:get_processor_list).returns([])
        File.expects(:exists?).with("/sys/devices/system/cpu").returns(true)
      end

      it "should be 2 via sysfs when cpu0 and cpu1 are present" do
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu[0-9]*").returns(sysfs_cpu_stubs(2))
        count = subject.get_processor_count
        expect(count).to eq "2"
      end

      it "should be 16 via sysfs when cpu0 through cpu15 are present" do
        Dir.stubs(:glob).with("/sys/devices/system/cpu/cpu[0-9]*").returns(sysfs_cpu_stubs(16))
        count = subject.get_processor_count
        expect(count).to eq "16"
      end
    end
  end

  describe "getting the physical processor count" do

    def sysfs_cpu_stubs(count)
      (0...count).map { |index| "/sys/devices/system/cpu/cpu#{index}/topology/physical_package_id" }
    end

    describe "when /sys/devices/system/cpu is available" do
      before :each do
        File.expects(:exists?).with("/sys/devices/system/cpu").returns(true)
      end

      it "should return 1 when there is 1 CPU with 1 core" do
        Dir.expects(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(sysfs_cpu_stubs(1))
        Facter::Core::Execution.expects(:exec).with("cat /sys/devices/system/cpu/cpu0/topology/physical_package_id").returns("0")
        count = subject.count_physical_cpu_from_sysfs
        expect(count).to eq "1"
      end

      it "should return 1 when there is 1 CPU with 4 cores" do
        Dir.expects(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(sysfs_cpu_stubs(4))
        sysfs_cpu_stubs(4).each do |file|
          Facter::Core::Execution.expects(:exec).with("cat #{file}").returns("0")
        end
        count = subject.count_physical_cpu_from_sysfs
        expect(count).to eq "1"
      end

      it "returns 4 when there are 4 CPUs each with one core" do
        Dir.expects(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(sysfs_cpu_stubs(4))
        sysfs_cpu_stubs(4).each_with_index do |file, i|
          Facter::Core::Execution.expects(:exec).with("cat #{file}").returns(i)
        end
        count = subject.count_physical_cpu_from_sysfs
        expect(count).to eq "4"
      end

      it "returns 4 when there are 4 CPUs each with two cores" do
        Dir.expects(:glob).with("/sys/devices/system/cpu/cpu*/topology/physical_package_id").returns(sysfs_cpu_stubs(8))
        sysfs_cpu_stubs(8).each_with_index do |file, i|
          Facter::Core::Execution.expects(:exec).with("cat #{file}").returns((i / 2).floor)
        end
        count = subject.count_physical_cpu_from_sysfs
        expect(count).to eq "4"
      end
    end

    describe "when the sysfs cpu directory is not available" do
      include FacterSpec::Cpuinfo
      it "returns 1 when there is 1 amd64 CPU with 2 cores" do
        Facter::Core::Execution.expects(:exec).with("grep 'physical.\+:' /proc/cpuinfo").returns(cpuinfo_fixture_read("amd64dual-grep"))
        count = subject.count_physical_cpu_from_cpuinfo
        expect(count).to eq "1"
      end

      it "returns 2 when there are 2 CPUs each with 1 core" do
        Facter::Core::Execution.expects(:exec).with("grep 'physical.\+:' /proc/cpuinfo").returns(cpuinfo_fixture_read("two_singlecore-grep"))
        count = subject.count_physical_cpu_from_cpuinfo
        expect(count).to eq "2"
      end

      it "returns 2 when there are 2 CPUS each with 2 cores" do
        Facter::Core::Execution.expects(:exec).with("grep 'physical.\+:' /proc/cpuinfo").returns(cpuinfo_fixture_read("two_multicore-grep"))
        count = subject.count_physical_cpu_from_cpuinfo
        expect(count).to eq "2"
      end

      it "returns 2 when there are 2 CPUs each with 12 cores" do
        Facter::Core::Execution.expects(:exec).with("grep 'physical.\+:' /proc/cpuinfo").returns(cpuinfo_fixture_read("amd64twentyfour-grep"))
        count = subject.count_physical_cpu_from_cpuinfo
        expect(count).to eq "2"
      end
    end
  end
end

describe Facter::Processor::Windows do
  subject { described_class.new }
  include_context "processor list"
  describe "getting the processor list" do
    it "should delegate to the windows_processor_list utility" do
      Facter::Processor::Util.expects(:windows_processor_list).once.returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    it "should use the length of its processor list" do
      subject.expects(:get_processor_list).returns(proc_list_array)
      count = subject.get_processor_count
      expect(count).to eq "2"
    end
  end

  describe "getting the physical processor count" do
    it "should delegate to the execquery utility" do
      ole = stub 'WIN32OLE'
      Facter::Util::WMI.expects(:execquery).with("select Name from Win32_Processor").returns(ole)
      ole.stubs(:Count).returns(4)
      count = subject.get_physical_processor_count
      expect(count).to eq "4"
    end
  end
end

describe Facter::Processor::Darwin do
  subject { described_class.new }
  include_context "processor list"

  before :each do
    Facter::Core::Execution.expects(:exec).with("/usr/sbin/system_profiler -xml SPHardwareDataType").returns(my_fixture_read("darwin-system-profiler"))
    subject.stubs(:query_system_profiler).returns({"number_processors" => 4, "current_processor_speed" => "2.3 GHz"})
    subject.instance_variable_set :@system_hardware_data, {"number_processors" => 4, "current_processor_speed" => "2.3 GHz"}
  end

  describe "getting the processor list" do
    it "should delegate to the enum_cpuinfo utility" do
      Facter::Processor::Util.expects(:enum_cpuinfo).once.returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    it "should delegate to the sysctl utility" do
      Facter::Util::POSIX.expects(:sysctl).with("hw.ncpu").once.returns("2")
      count = subject.get_processor_count
      expect(count).to eq "2"
    end
  end

  describe "getting the physical processor count" do
    it "should use system_profiler" do
      count = subject.get_physical_processor_count
      expect(count).to eq "4"
    end
  end

  describe "getting the processor speed" do
    it "should use system_profiler" do
      subject.instance_variable_set :@system_hardware_data, {"number_processors" => 4, "current_processor_speed" => "2.4 GHz"}
      speed = subject.get_processor_speed
      expect(speed).to eq "2.4 GHz"
    end
  end
end

describe Facter::Processor::AIX do
  subject { described_class.new }
  include_context "processor list"

  describe "getting the processor list" do
    it "should delegate to the aix_processor_list utility" do
      Facter::Processor::Util.expects(:aix_processor_list).returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    it "should use the length of its processor list" do
      subject.expects(:get_processor_list).once.returns(proc_list_array)
      count = subject.get_processor_count
      expect(count).to eq "2"
    end
  end
end

describe Facter::Processor::HP_UX do
  subject { described_class.new }
  include_context "processor list"

  describe "getting the processor list" do
    it "should delegate to the hpux_processor_list utility" do
      Facter::Processor::Util.expects(:hpux_processor_list).once.returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    it "should use the length of its processor list" do
      subject.expects(:get_processor_list).once.returns(proc_list_array)
      count = subject.get_processor_count
      expect(count).to eq "2"
    end
  end
end

describe Facter::Processor::BSD do
  subject { described_class.new }
  include_context "processor list"

  describe "getting the processor list" do
    it "should delegate to the enum_cpuinfo utility" do
      Facter::Processor::Util.expects(:enum_cpuinfo).once.returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    it "should delegate to the sysctl utility" do
      Facter::Util::POSIX.expects(:sysctl).with("hw.ncpu").once.returns("2")
      count = subject.get_processor_count
      expect(count).to eq "2"
    end
  end

  describe "getting the processor model" do
    it "should delegate to the sysctl utility" do
      Facter::Util::POSIX.expects(:sysctl).with("hw.model").once.returns("SomeVendor CPU 4.2GHz")
      model = subject.get_processor_model
      expect(model).to eq "SomeVendor CPU 4.2GHz"
    end
  end
end

describe Facter::Processor::OpenBSD do
  subject { described_class.new }
  include_context "processor list"

  describe "getting the physical processor count" do
    it "should delegate to the sysctl utility" do
      Facter::Util::POSIX.expects(:sysctl).with("hw.ncpufound").once.returns("2")
      count = subject.get_physical_processor_count
      expect(count).to eq "2"
    end
  end
end

describe Facter::Processor::SunOS do
  subject { described_class.new }
  include_context "processor list"

  describe "getting the processor list" do
    it "should delegate to the enum_kstat utility" do
      Facter::Processor::Util.expects(:enum_kstat).once.returns(proc_list_array)
      list = subject.get_processor_list
      expect(list).to eq proc_list_array
    end
  end

  describe "getting the processor count" do
    describe "with version 5.7 or older" do
      it "should count processors returned from kstat" do
        Facter.fact(:kernelrelease).stubs(:value).returns("5.7")
        subject.expects(:count_cpu_with_kstat).once.returns("2")
        count = subject.get_processor_count
        expect(count).to eq "2"
      end
    end

    describe "with version 5.8 or newer" do
      it "should count processors using psrinfo" do
        Facter.fact(:kernelrelease).stubs(:value).returns("5.8")
        subject.expects(:count_cpu_with_psrinfo).once.returns("2")
        count = subject.get_processor_count
        expect(count).to eq "2"
      end
    end
  end

  describe "getting the physical processor count" do
    describe "with version 5.7 or older" do
      it "should use psrinfo without the 'p' flag" do
        Facter.fact(:kernelrelease).stubs(:value).returns("5.7")
        Facter::Core::Execution.expects(:exec).with("/usr/sbin/psrinfo").once.returns(my_fixture_read("solaris-psrinfo"))
        count = subject.get_physical_processor_count
        expect(count).to eq "2"
      end
    end

    describe "with version 5.8 or newer" do
      it "should use psrinfo with the 'p' flag" do
        Facter.fact(:kernelrelease).stubs(:value).returns("5.8")
        Facter::Core::Execution.expects(:exec).with("/usr/sbin/psrinfo -p").once.returns("2")
        count = subject.get_physical_processor_count
        expect(count).to eq "2"
      end
    end
  end
end
