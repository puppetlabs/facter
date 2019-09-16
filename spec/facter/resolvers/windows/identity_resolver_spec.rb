# frozen_string_literal: true

describe 'Windows IdentityResolver' do
  before do
    size_ptr = double('FFI::MemoryPointer', read_uint32: 1)
    name_ptr = double('FFI::MemoryPointer', read_wide_string: user_name)

    allow(FFI::MemoryPointer).to receive(:new).with(:win32_ulong, 1).and_return(size_ptr)
    allow(IdentityFFI).to receive(:GetUserNameExW).with(2, FFI::Pointer::NULL, size_ptr)
    FFI.define_errno(error_number)
    allow(FFI::MemoryPointer).to receive(:new).with(:wchar, size_ptr.read_uint32).and_return(name_ptr)
    allow(IdentityFFI).to receive(:GetUserNameExW).with(2, name_ptr, size_ptr).and_return(error_geting_user?)
    allow(IdentityFFI).to receive(:IsUserAnAdmin).and_return(admin?)
  end
  after do
    Facter::Resolvers::IdentityResolver.invalidate_cache
  end

  context '#resolve when user is administrator' do
    let(:user_name) { 'MG93C9IN9WKOITF\Administrator' }
    let(:error_number) { FFI::ERROR_MORE_DATA }
    let(:error_geting_user?) { 1 }
    let(:admin?) { 1 }

    it 'detects user' do
      expect(Facter::Resolvers::IdentityResolver.resolve(:user)).to eql('MG93C9IN9WKOITF\Administrator')
    end
    it 'detects that user is administrator' do
      expect(Facter::Resolvers::IdentityResolver.resolve(:privileged)).to eql(true)
    end
  end

  context '#resolve when user is not administrator' do
    let(:user_name) { 'MG93C9IN9WKOITF\User' }
    let(:error_number) { FFI::ERROR_MORE_DATA }
    let(:error_geting_user?) { 1 }
    let(:admin?) { 0 }

    it 'detects user' do
      expect(Facter::Resolvers::IdentityResolver.resolve(:user)).to eql('MG93C9IN9WKOITF\User')
    end
    it 'detects that user is not administrator' do
      expect(Facter::Resolvers::IdentityResolver.resolve(:privileged)).to eql(false)
    end
  end

  context '#resolve when' do
    let(:user_name) { 'MG93C9IN9WKOITF\User' }
    let(:error_number) { FFI::ERROR_MORE_DATA }
    let(:error_geting_user?) { 1 }
    let(:admin?) { nil }

    it 'detects user' do
      expect(Facter::Resolvers::IdentityResolver.resolve(:user)).to eql('MG93C9IN9WKOITF\User')
    end
    it 'could not determine if user is admin' do
      expect(Facter::Resolvers::IdentityResolver.resolve(:privileged)).to eql(nil)
    end
  end

  context '#resolve when error code is different than ERROR_MORE_DATA' do
    let(:user_name) { '' }
    let(:error_number) { nil }
    let(:error_geting_user?) { 1 }
    let(:admin?) { 0 }

    it 'logs debug message when trying to resolve user' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with("failure resolving identity facts: #{error_number}")
      expect(Facter::Resolvers::IdentityResolver.resolve(:user)).to eql(nil)
    end
    it 'logs debug message when trying to find if user is privileged' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with("failure resolving identity facts: #{error_number}")
      expect(Facter::Resolvers::IdentityResolver.resolve(:privileged)).to eql(nil)
    end
  end

  context '#resolve when there is an error getting user name' do
    let(:user_name) { '' }
    let(:error_number) { FFI::ERROR_MORE_DATA }
    let(:error_geting_user?) { 0 }
    let(:admin?) { 0 }

    it 'logs debug message when trying to resolve user' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with("failure resolving identity facts: #{error_number}")
      expect(Facter::Resolvers::IdentityResolver.resolve(:user)).to eql(nil)
    end
    it 'logs debug message when trying to find if user is privileged' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with("failure resolving identity facts: #{error_number}")
      expect(Facter::Resolvers::IdentityResolver.resolve(:privileged)).to eql(nil)
    end
  end
end
