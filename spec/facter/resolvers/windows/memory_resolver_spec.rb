# frozen_string_literal: true

describe Facter::Resolvers::Memory do
  before do
    state_ptr = double('FFI::MemoryPointer', size: nil)
    state = double('PerformanceInformation', size: nil)

    allow(FFI::MemoryPointer).to receive(:new).with(PerformanceInformation.size).and_return(state_ptr)
    allow(MemoryFFI).to receive(:GetPerformanceInfo).with(state_ptr, state_ptr.size).and_return(status)

    allow(PerformanceInformation).to receive(:new).with(state_ptr).and_return(state)

    allow(state).to receive(:[]).with(:PhysicalTotal).and_return(total)
    allow(state).to receive(:[]).with(:PageSize).and_return(page_size)
    allow(state).to receive(:[]).with(:PhysicalAvailable).and_return(available)
  end

  after do
    Facter::Resolvers::Memory.invalidate_cache
  end

  describe '#resolve' do
    let(:status) { 1 }
    let(:total) { 1_048_313 }
    let(:page_size) { 4096 }
    let(:available) { 824_031 }

    it 'detects total bytes' do
      expect(Facter::Resolvers::Memory.resolve(:total_bytes)).to be(4_293_890_048)
    end

    it 'detects available bytes' do
      expect(Facter::Resolvers::Memory.resolve(:available_bytes)).to be(3_375_230_976)
    end

    it 'determines used bytes' do
      expect(Facter::Resolvers::Memory.resolve(:used_bytes)).to be(918_659_072)
    end

    it 'determines capacity' do
      expect(Facter::Resolvers::Memory.resolve(:capacity)).to eql('21.39%')
    end
  end

  describe '#resolve when total bytes is 0' do
    let(:status) { 1 }
    let(:total) { 0 }
    let(:page_size) { 4096 }
    let(:available) { 23 }

    it 'detects total_bytes as nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Available or Total bytes are zero could not proceed further')
      expect(Facter::Resolvers::Memory.resolve(:total_bytes)).to be(nil)
    end

    it 'detects available bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:available_bytes)).to be(nil)
    end

    it 'determines used bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:used_bytes)).to be(nil)
    end

    it 'determines capacity as nil' do
      expect(Facter::Resolvers::Memory.resolve(:capacity)).to be(nil)
    end
  end

  describe '#resolve when available bytes is 0' do
    let(:status) { 1 }
    let(:total) { 3242 }
    let(:page_size) { 4096 }
    let(:available) { 0 }

    it 'detects total bytes as nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Available or Total bytes are zero could not proceed further')
      expect(Facter::Resolvers::Memory.resolve(:total_bytes)).to be(nil)
    end

    it 'detects available bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:available_bytes)).to be(nil)
    end

    it 'determines used bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:used_bytes)).to be(nil)
    end

    it 'determines capacity as nil' do
      expect(Facter::Resolvers::Memory.resolve(:capacity)).to be(nil)
    end
  end

  describe '#resolve when page size is 0' do
    let(:status) { 1 }
    let(:total) { 3242 }
    let(:page_size) { 0 }
    let(:available) { 4096 }

    it 'detects total bytes as nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('Available or Total bytes are zero could not proceed further')
      expect(Facter::Resolvers::Memory.resolve(:total_bytes)).to be(nil)
    end

    it 'detects available bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:available_bytes)).to be(nil)
    end

    it 'determines used bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:used_bytes)).to be(nil)
    end

    it 'determines capacity as nil' do
      expect(Facter::Resolvers::Memory.resolve(:capacity)).to be(nil)
    end
  end

  describe '#resolve when GetPerformanceInfo function fails' do
    let(:status) { FFI::WIN32FALSE }
    let(:total) { 1_048_313 }
    let(:page_size) { 4096 }
    let(:available) { 824_031 }

    it 'logs debug message and detects total bytes as nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('Resolving memory facts failed')
      expect(Facter::Resolvers::Memory.resolve(:total_bytes)).to be(nil)
    end

    it 'detects available bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:available_bytes)).to be(nil)
    end

    it 'determines used bytes as nil' do
      expect(Facter::Resolvers::Memory.resolve(:used_bytes)).to be(nil)
    end

    it 'determines capacity as nil' do
      expect(Facter::Resolvers::Memory.resolve(:capacity)).to be(nil)
    end
  end
end
