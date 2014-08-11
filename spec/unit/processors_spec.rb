require 'spec_helper'
require 'facter/processors/os'
require 'facter/util/processor'

describe "processors" do
  subject { Facter.fact(:processors) }
  let(:os) { stub('OS Object') }
  let(:proc_list_array) { ["Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz", "Intel(R) Xeon(R) CPU E5-2609 0 @ 2.40GHz"] }

  shared_examples "all operating systems" do
    it "should include a models key with all processors" do
      expect(subject.value["models"]).to eq proc_list_array
    end

    it "should include a count key with the number of processors" do
      expect(subject.value["count"]).to eq 8
    end
  end

  describe "In OSX" do
    before do
      Facter::Processors::Darwin.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Darwin")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_speed).returns("2.4 GHz")
    end

    it_behaves_like "all operating systems"

    it "should include a speed key with the processor speed" do
      expect(subject.value["speed"]).to eq "2.4 GHz"
    end
  end

  describe "In Linux" do
    before do
      Facter::Processors::Linux.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("Linux")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(4)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalcount key with the number of physical processors" do
      expect(subject.value["physicalcount"]).to eq 4
    end
  end

  describe "In Windows" do
    before do
      Facter::Processors::Windows.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("windows")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(4)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalcount key with the number of physical processors" do
      expect(subject.value["physicalcount"]).to eq 4
    end
  end

  describe "In SunOS" do
    before do
      Facter::Processors::SunOS.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(4)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalcount key with the number of physical processors" do
      expect(subject.value["physicalcount"]).to eq 4
    end
  end

  describe "In Dragonfly and FreeBSD" do
    before do
      Facter::Processors::BSD.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("FreeBSD")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"
  end

  describe "OpenBSD" do
    before do
      Facter::Processors::OpenBSD.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("OpenBSD")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(4)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"

    it "should include a physicalcount key with the number of physical processors" do
      expect(subject.value["physicalcount"]).to eq 4
    end
  end

  describe "In GNU/kFreeBSD" do
    before do
      Facter::Processors::GNU.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("GNU/kFreeBSD")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"
  end

  describe "In AIX" do
    before do
      Facter::Processors::AIX.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("AIX")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"
  end

  describe "In HP-UX" do
    before do
      Facter::Processors::HP_UX.stubs(:new).returns os
    end

    before :each do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns("HP-UX")
      os.stubs(:get_processor_list).returns(proc_list_array)
      os.stubs(:get_processor_count).returns(8)
      os.stubs(:get_physical_processor_count).returns(nil)
      os.stubs(:get_processor_speed).returns(nil)
    end

    it_behaves_like "all operating systems"
  end

  describe "In non-supported kernels" do
    before do
      Facter.fact(:kernel).stubs(:value).returns("Foo")
    end

    it "should not resolve the processors fact" do
      Facter::Processors.expects(:implementation).returns(nil)
      expect(subject.value).to be_nil
    end
  end
end
