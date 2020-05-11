# frozen_string_literal: true

describe Facter::Bsd::FfiHelper do
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
