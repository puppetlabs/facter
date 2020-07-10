# frozen_string_literal: true

describe Facter::Resolvers::Kernel do
  let(:logger) { instance_spy(Facter::Log) }

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

    Facter::Resolvers::Kernel.instance_variable_set(:@log, logger)
  end

  after do
    Facter::Resolvers::Kernel.invalidate_cache
  end

  describe '#resolve' do
    let(:status) { KernelFFI::STATUS_SUCCESS }
    let(:maj) { 10 }
    let(:min) { 0 }
    let(:buildnr) { 123 }

    it 'detects kernel version' do
      expect(Facter::Resolvers::Kernel.resolve(:kernelversion)).to eql('10.0.123')
    end

    it 'detects kernel major version' do
      expect(Facter::Resolvers::Kernel.resolve(:kernelmajorversion)).to eql('10.0')
    end

    it 'detects kernel name' do
      expect(Facter::Resolvers::Kernel.resolve(:kernel)).to eql('windows')
    end
  end

  describe '#resolve when RtlGetVersion function fails to get os version information' do
    let(:status) { 10 }
    let(:maj) { 10 }
    let(:min) { 0 }
    let(:buildnr) { 123 }

    it 'logs debug message and kernel version nil' do
      allow(logger).to receive(:debug).with('Calling Windows RtlGetVersion failed')
      expect(Facter::Resolvers::Kernel.resolve(:kernelversion)).to be(nil)
    end

    it 'detects that kernel major version is nil' do
      expect(Facter::Resolvers::Kernel.resolve(:kernelmajorversion)).to be(nil)
    end

    it 'detects that kernel name is nil' do
      expect(Facter::Resolvers::Kernel.resolve(:kernel)).to be(nil)
    end
  end
end
