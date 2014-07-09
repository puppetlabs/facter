require 'spec_helper'
require 'facter/processors/os'
require 'facter/processors/util'

describe "processors" do
  subject { Facter.fact("processors") }
  let(:os) { stub('OS Object') }
  let(:proc_list_array) { ["Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz", "Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz"] }
  let(:expected_proc_list) { {"Processor0"=>"Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz", "Processor1"=>"Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz"} }

  shared_examples "all operating systems" do
    it "should include a processorlist key with all processors" do
      expect(subject.value["processorlist"]).to eq expected_proc_list
    end

    it "should include a processorcount key with the number of processors" do
      expect(subject.value["processorcount"]).to eq "8"
    end
  end

  describe "In OSX" do
    before do
      Facter::Processor::Darwin.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns("4")
      os.stubs(:get_processor_model).returns(nil)
      os.stubs(:get_processor_speed).returns("2.4 GHz")
    end

    it_behaves_like "all operating systems"

    it "should include a physicalprocessorcount key with the number of physical processors" do
      expect(subject.value["physicalprocessorcount"]).to eq "4"
    end

    it "should include a processor speed key with the processor speed" do
      expect(subject.value["processorspeed"]).to eq "2.4 GHz"
    end
  end

  describe "In Linux" do
    before do
      Facter::Processor::Linux.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns("4")
      os.stubs(:get_processor_model).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalprocessorcount key with the number of physical processors" do
      expect(subject.value["physicalprocessorcount"]).to eq "4"
    end
  end

  describe "In Windows" do
    before do
      Facter::Processor::Windows.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("windows")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns("4")
      os.stubs(:get_processor_model).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalprocessorcount key with the number of physical processors" do
      expect(subject.value["physicalprocessorcount"]).to eq "4"
    end
  end

  describe "In SunOS" do
    before do
      Facter::Processor::SunOS.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns("4")
      os.stubs(:get_processor_model).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalprocessorcount key with the number of physical processors" do
      expect(subject.value["physicalprocessorcount"]).to eq "4"
    end
  end

  describe "In Dragonfly and FreeBSD" do
    before do
      Facter::Processor::BSD.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_model).returns("SomeVendor CPU")
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a processor key with the processor model" do
      expect(subject.value["processor"]).to eq "SomeVendor CPU"
    end
  end

  describe "OpenBSD" do
    before do
      Facter::Processor::OpenBSD.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns("4")
      os.stubs(:get_processor_model).returns("SomeVendor CPU")
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalprocessorcount key with the number of physical processors" do
      expect(subject.value["physicalprocessorcount"]).to eq "4"
    end

    it "should include a processor key with the processor model" do
      expect(subject.value["processor"]).to eq "SomeVendor CPU"
    end
  end

  describe "In AIX" do
    before do
      Facter::Processor::AIX.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("aix")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_model).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"
  end

  describe "In HP-UX" do
    before do
      Facter::Processor::HP_UX.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("hp-ux")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns("8")
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_model).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"
  end
end
