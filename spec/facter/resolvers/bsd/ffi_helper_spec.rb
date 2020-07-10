# frozen_string_literal: true

describe Facter::Bsd::FfiHelper do
  describe '#read_load_averages' do
    let(:averages) { double('FFI::MemoryPointer', size: 24) }

    before do
      allow(FFI::MemoryPointer).to receive(:new).with(:double, 3).and_return(averages)
    end

    after do
      Facter::Resolvers::Bsd::LoadAverages.invalidate_cache
    end

    it 'returns load average' do
      allow(Facter::Bsd::FfiHelper::Libc).to receive(:getloadavg).and_return(3)
      allow(averages).to receive(:read_array_of_double).with(3).and_return([0.19482421875, 0.2744140625, 0.29296875])

      expect(Facter::Bsd::FfiHelper.read_load_averages).to eq([0.19482421875, 0.2744140625, 0.29296875])
    end

    it 'does not return load average' do
      allow(Facter::Bsd::FfiHelper::Libc).to receive(:getloadavg).and_return(-1)
      expect(Facter::Bsd::FfiHelper.read_load_averages).to be_nil
    end
  end

  describe '#sysctl' do
    let(:oids) { [1, 2, 3] }
    let(:name) { double('FFI::MemoryPointer') }
    let(:oldlenp) { double('FFI::MemoryPointer') }
    let(:oldp) { double('FFI::MemoryPointer') }

    before do
      allow(FFI::MemoryPointer).to receive(:new).with(:uint, oids.size).and_return(name)
      allow(name).to receive(:write_array_of_uint).with(oids)
    end

    context 'when expecting a string' do
      let(:result) { 'Hello World !' }

      before do
        allow(FFI::MemoryPointer).to receive(:new)
          .with(:size_t)
          .and_return(oldlenp)
        allow(Facter::Bsd::FfiHelper::Libc).to receive(:sysctl)
          .with(name, oids.size, FFI::Pointer::NULL, oldlenp, FFI::Pointer::NULL, 0)
          .and_return(0)
        allow(oldlenp).to receive(:read)
          .with(:size_t)
          .and_return(result.length)
        allow(FFI::MemoryPointer).to receive(:new)
          .with(:uint8_t, result.length)
          .and_return(oldp)
        allow(Facter::Bsd::FfiHelper::Libc).to receive(:sysctl)
          .with(name, oids.size, oldp, oldlenp, FFI::Pointer::NULL, 0)
          .and_return(0)
        allow(oldp).to receive(:read_string)
          .and_return(result)
      end

      it 'does what is expected' do
        expect(Facter::Bsd::FfiHelper.sysctl(:string, oids)).to eq(result)
      end
    end

    context 'when expecting an uint32_t' do
      let(:result) { 42 }
      let(:oldlen) { instance_double('Integer') }

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
        allow(Facter::Bsd::FfiHelper::Libc).to receive(:sysctl)
          .with(name, oids.size, oldp, oldlenp, FFI::Pointer::NULL, 0)
          .and_return(0)
        allow(oldp).to receive(:read)
          .with(:uint32_t)
          .and_return(result)
      end

      it 'does what is expected' do
        expect(Facter::Bsd::FfiHelper.sysctl(:uint32_t, oids)).to eq(result)
      end
    end
  end
end
