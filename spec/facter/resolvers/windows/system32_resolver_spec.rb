# frozen_string_literal: true

describe 'Windows System32Resolver' do
  before do
    path_ptr = double('FFI::MemoryPointer', read_wide_string: win_path)
    bool_ptr = double('FFI::MemoryPointer', read_win32_bool: is_wow)

    allow(FFI::MemoryPointer).to receive(:new).with(:wchar, FFI::MAX_PATH + 1).and_return(path_ptr)
    allow(System32FFI).to receive(:SHGetFolderPathW)
      .with(0, System32FFI::CSIDL_WINDOWS, 0, 0, path_ptr)
      .and_return(status)

    allow(path_ptr).to receive(:read_wide_string).with(FFI::MAX_PATH).and_return(win_path)

    allow(FFI::MemoryPointer).to receive(:new).with(:win32_bool, 1).and_return(bool_ptr)
    allow(System32FFI).to receive(:GetCurrentProcess).and_return(2)
    allow(System32FFI).to receive(:IsWow64Process).with(2, bool_ptr).and_return(bool)
  end
  after do
    Facter::Resolvers::System32Resolver.invalidate_cache
  end

  context '#resolve when is wow 64 process' do
    let(:status) { 0 }
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 1 }
    let(:is_wow) { true }

    it 'detects sysnative dir' do
      expect(Facter::Resolvers::System32Resolver.resolve(:system32)).to eql("#{win_path}\\sysnative")
    end
  end

  context '#resolve when it is not wow 64 process' do
    let(:status) { 0 }
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 1 }
    let(:is_wow) { false }

    it 'detects system32 dir' do
      expect(Facter::Resolvers::System32Resolver.resolve(:system32)).to eql("#{win_path}\\system32")
    end
  end

  context '#resolve when SHGetFolderPathW fails' do
    let(:status) { 1 }
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 1 }
    let(:is_wow) { false }

    it 'detects system32 dir is nil and prints debug message' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('SHGetFolderPath failed')
      expect(Facter::Resolvers::System32Resolver.resolve(:system32)).to eql(nil)
    end
  end

  context '#resolve when IsWow64Process fails' do
    let(:status) { 0 }
    let(:win_path) { 'C:\\Windows' }
    let(:bool) { 0 }
    let(:is_wow) { false }

    it 'detects system32 dir is nil and prints debug message' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('IsWow64Process failed')
      expect(Facter::Resolvers::System32Resolver.resolve(:system32)).to eql(nil)
    end
  end
end
