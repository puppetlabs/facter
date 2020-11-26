# frozen_string_literal: true

describe Facter::Util::Resolvers::Ffi::LoadAverages do
  describe '#load_averages' do
    let(:memory_pointer) { instance_spy(FFI::MemoryPointer) }

    before do
      allow(Facter::Util::Resolvers::Ffi::LoadAverages).to receive(:getloadavg).and_return(response)
      allow(FFI::MemoryPointer).to receive(:new).with(:double, 3).and_return(memory_pointer)
      allow(memory_pointer).to receive(:read_array_of_double).with(response).and_return(averages)
    end

    context 'when averages are returned' do
      let(:response) { 3 }
      let(:averages) { [0.19482421875, 0.2744140625, 0.29296875] }

      it 'returns load average' do
        expect(Facter::Util::Resolvers::Ffi::LoadAverages.read_load_averages).to eq(averages)
      end
    end

    context 'when averages are not returned' do
      let(:response) { -1 }
      let(:averages) { nil }

      it 'does not return load average' do
        expect(Facter::Util::Resolvers::Ffi::LoadAverages.read_load_averages).to eq(averages)
      end
    end
  end
end
