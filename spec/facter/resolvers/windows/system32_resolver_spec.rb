# frozen_string_literal: true

describe Facter::Resolvers::System32 do
  before do
    allow(ENV).to receive(:[]).with('SystemRoot').and_return(win_path)

    bool_ptr = double('FFI::MemoryPointer', read_win32_bool: is_wow)
    allow(FFI::MemoryPointer).to receive(:new).with(:win32_bool, 1).and_return(bool_ptr)
    allow(System32FFI).to receive(:GetCurrentProcess).and_return(2)
    allow(System32FFI).to receive(:IsWow64Process).with(2, bool_ptr).and_return(bool)
  end

  after do
    Facter::Resolvers::System32.invalidate_cache
  end

  describe '#resolve when is wow 64 process' do
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 1 }
    let(:is_wow) { true }

    it 'detects sysnative dir' do
      expect(Facter::Resolvers::System32.resolve(:system32)).to eql("#{win_path}\\sysnative")
    end
  end

  describe '#resolve when it is not wow 64 process' do
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 1 }
    let(:is_wow) { false }

    it 'detects system32 dir' do
      expect(Facter::Resolvers::System32.resolve(:system32)).to eql("#{win_path}\\system32")
    end
  end

  describe '#resolve when env variable is not set' do
    let(:win_path) { '' }
    let(:bool) { 1 }
    let(:is_wow) { false }

    it 'detects system32 dir is nil and prints debug message' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('Unable to find correct value for SystemRoot'\
                                                                                            ' enviroment variable')
      expect(Facter::Resolvers::System32.resolve(:system32)).to be(nil)
    end
  end

  describe '#resolve when env variable is found as nil' do
    let(:win_path) { nil }
    let(:bool) { 1 }
    let(:is_wow) { false }

    it 'detects system32 dir is nil and prints debug message' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('Unable to find correct value for SystemRoot'\
                                                                                            ' enviroment variable')
      expect(Facter::Resolvers::System32.resolve(:system32)).to be(nil)
    end
  end

  describe '#resolve when IsWow64Process fails' do
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 0 }
    let(:is_wow) { false }

    it 'detects system32 dir is nil and prints debug message' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('IsWow64Process failed')
      expect(Facter::Resolvers::System32.resolve(:system32)).to be(nil)
    end
  end
end
