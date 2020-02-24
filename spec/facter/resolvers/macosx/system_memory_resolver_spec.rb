# frozen_string_literal: true

describe Facter::Resolvers::Macosx::SystemMemory do
  let(:available_bytes) { 5_590_519_808 }
  let(:total_bytes) { 34_359_738_368 }
  let(:used_bytes) { 28_769_218_560 }
  let(:capacity) { '83.73%' }

  before do
    allow(Open3).to receive(:capture2)
      .with('sysctl -n hw.memsize')
      .and_return(['34359738368', ''])

    allow(Open3).to receive(:capture2)
      .with('vm_stat')
      .and_return([load_fixture('vm_stat').read, ''])
  end

  it 'returns available system memory in bytes' do
    result = Facter::Resolvers::Macosx::SystemMemory.resolve(:available_bytes)
    expect(result).to eq(available_bytes)
  end

  it 'returns total system memory in bytes' do
    result = Facter::Resolvers::Macosx::SystemMemory.resolve(:total_bytes)
    expect(result).to eq(total_bytes)
  end

  it 'returns total system memory in bytes' do
    result = Facter::Resolvers::Macosx::SystemMemory.resolve(:used_bytes)
    expect(result).to eq(used_bytes)
  end

  it 'returns total system memory in bytes' do
    result = Facter::Resolvers::Macosx::SystemMemory.resolve(:capacity)
    expect(result).to eq(capacity)
  end
end
