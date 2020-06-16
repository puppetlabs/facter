# frozen_string_literal: true

describe Facter::Freebsd::FfiHelper do
  describe '#sysctl_by_name' do
    let(:name) { 'foo.bar.baz' }
    let(:oldlenp) { double('FFI::MemoryPointer') }
    let(:oldp) { double('FFI::MemoryPointer') }

    context 'when expecting a string' do
      let(:result) { 'Hello World !' }

      before do
        allow(FFI::MemoryPointer).to receive(:new)
          .with(:size_t)
          .and_return(oldlenp)
        allow(Facter::Freebsd::FfiHelper::Libc).to receive(:sysctlbyname)
          .with(name, FFI::Pointer::NULL, oldlenp, FFI::Pointer::NULL, 0)
          .and_return(0)
        allow(oldlenp).to receive(:read)
          .with(:size_t)
          .and_return(result.length)
        allow(FFI::MemoryPointer).to receive(:new)
          .with(:uint8_t, result.length)
          .and_return(oldp)
        allow(Facter::Freebsd::FfiHelper::Libc).to receive(:sysctlbyname)
          .with(name, oldp, oldlenp, FFI::Pointer::NULL, 0)
          .and_return(0)
        allow(oldp).to receive(:read_string)
          .and_return(result)
      end

      it 'does what is expected' do
        expect(Facter::Freebsd::FfiHelper.sysctl_by_name(:string, name)).to eq(result)
      end
    end

    context 'when expecting an uint32_t' do
      let(:result) { 42 }
      let(:oldlen) { double('Integer') }

      before do
        allow(FFI::MemoryPointer).to receive(:new)
          .with(:size_t)
          .and_return(oldlenp)
        allow(FFI).to receive(:type_size)
          .with(:uint32_t)
          .and_return(4)
        allow(oldlenp).to receive(:write)
          .with(:size_t, 4)
        allow(oldlenp).to receive(:read)
          .and_return(oldlen)
        allow(FFI::MemoryPointer).to receive(:new)
          .with(:uint8_t, oldlen)
          .and_return(oldp)
        allow(Facter::Freebsd::FfiHelper::Libc).to receive(:sysctlbyname)
          .with(name, oldp, oldlenp, FFI::Pointer::NULL, 0)
          .and_return(0)
        allow(oldp).to receive(:read)
          .with(:uint32_t)
          .and_return(result)
      end

      it 'does what is expected' do
        expect(Facter::Freebsd::FfiHelper.sysctl_by_name(:uint32_t, name)).to eq(result)
      end
    end
  end
end
