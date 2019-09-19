# frozen_string_literal: true

describe 'Windows MemoryResolver' do
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
    MemoryResolver.invalidate_cache
  end

  context '#resolve' do
    let(:status) { 1 }
    let(:total) { 1_048_313 }
    let(:page_size) { 4096 }
    let(:available) { 824_031 }

    it 'detects total bytes' do
      expect(MemoryResolver.resolve(:total_bytes)).to eql(4_293_890_048)
    end
    it 'detects available bytes' do
      expect(MemoryResolver.resolve(:available_bytes)).to eql(3_375_230_976)
    end
    it 'determines used bytes' do
      expect(MemoryResolver.resolve(:used_bytes)).to eql(918_659_072)
    end
    it 'determines capacity' do
      expect(MemoryResolver.resolve(:capacity)).to eql('21.39%')
    end
  end

  context '#resolve when GetPerformanceInfo function fails' do
    let(:status) { FFI::WIN32_FALSE }
    let(:total) { 1_048_313 }
    let(:page_size) { 4096 }
    let(:available) { 824_031 }

    it 'logs debug message and detects total bytes as nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('Resolving memory facts failed')
      expect(MemoryResolver.resolve(:total_bytes)).to eql(nil)
    end
    it 'detects available bytes as nil' do
      expect(MemoryResolver.resolve(:available_bytes)).to eql(nil)
    end
    it 'determines used bytes as nil' do
      expect(MemoryResolver.resolve(:used_bytes)).to eql(nil)
    end
    it 'determines capacity as nil' do
      expect(MemoryResolver.resolve(:capacity)).to eql(nil)
    end
  end
end
