# frozen_string_literal: true

describe 'Windows KernelResolver' do
  before do
    ver_ptr = double('FFI::MemoryPointer')
    ver = double('OsVersionInfoEx', size: nil)

    allow(FFI::MemoryPointer).to receive(:new).with(OsVersionInfoEx.size).and_return(ver_ptr)
    allow(OsVersionInfoEx).to receive(:new).with(ver_ptr).and_return(ver)

    allow(ver).to receive(:[]=).with(:dwOSVersionInfoSize, ver.size)
    allow(KernelFFI).to receive(:RtlGetVersion).with(ver_ptr).and_return(status)

    allow(ver).to receive(:[]).with(:dwMajorVersion).and_return(maj)
    allow(ver).to receive(:[]).with(:dwMinorVersion).and_return(min)
    allow(ver).to receive(:[]).with(:dwBuildNumber).and_return(buildnr)
  end
  after do
    KernelResolver.invalidate_cache
  end

  context '#resolve' do
    let(:status) { KernelFFI::STATUS_SUCCESS }
    let(:maj) { 10 }
    let(:min) { 0 }
    let(:buildnr) { 123 }

    it 'detects kernel version' do
      expect(KernelResolver.resolve(:kernelversion)).to eql('10.0.123')
    end
    it 'detects kernel major version' do
      expect(KernelResolver.resolve(:kernelmajorversion)).to eql('10.0')
    end
    it 'detects kernel name' do
      expect(KernelResolver.resolve(:kernel)).to eql('windows')
    end
  end

  context '#resolve when RtlGetVersion function fails to get os version information' do
    let(:status) { 10 }
    let(:maj) { 10 }
    let(:min) { 0 }
    let(:buildnr) { 123 }

    it 'logs debug message and kernel version nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug).with('Calling Windows RtlGetVersion failed')
      expect(KernelResolver.resolve(:kernelversion)).to eql(nil)
    end
    it 'detects that kernel major version is nil' do
      expect(KernelResolver.resolve(:kernelmajorversion)).to eql(nil)
    end
    it 'detects that kernel name is nil' do
      expect(KernelResolver.resolve(:kernel)).to eql(nil)
    end
  end
end
