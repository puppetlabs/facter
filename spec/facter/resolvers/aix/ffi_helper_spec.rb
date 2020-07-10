# frozen_string_literal: true

describe Facter::Aix::FfiHelper do
  let(:averages) { double('FFI::MemoryPointer', size: 24) }
  let(:averages_size) { double('FFI::MemoryPointer', write_int: 24) }

  before do
    allow(FFI::MemoryPointer).to receive(:new).with(:long_long, 3).and_return(averages)
    allow(FFI::MemoryPointer).to receive(:new).with(:int, 1).and_return(averages_size)
  end

  after do
    Facter::Resolvers::Aix::LoadAverages.invalidate_cache
  end

  it 'returns load average' do
    allow(Facter::Aix::FfiHelper::Libc).to receive(:getkerninfo).and_return(0)
    allow(averages).to receive(:read_array_of_long_long).with(3).and_return([655.36, 1310.72, 1966.08])

    expect(Facter::Aix::FfiHelper.read_load_averages).to eq([0.01, 0.02, 0.03])
  end

  it 'does not return load average' do
    allow(Facter::Aix::FfiHelper::Libc).to receive(:getkerninfo).and_return(-1)
    expect(Facter::Aix::FfiHelper.read_load_averages).to be_nil
  end
end
