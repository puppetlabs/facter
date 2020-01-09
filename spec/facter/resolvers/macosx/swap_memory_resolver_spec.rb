# frozen_string_literal: true

describe 'SwapMemoryResolver' do
  let(:available_bytes) { 1_729_363_968 }
  let(:total_bytes) { 3_221_225_472 }
  let(:used_bytes) { 1_491_861_504 }
  let(:capacity) { '46.31%' }
  let(:encrypted) { true }

  before do
    allow(Open3).to receive(:capture2)
      .with('sysctl -n vm.swapusage')
      .and_return(['total = 3072.00M  used = 1422.75M  free = 1649.25M  (encrypted)', ''])
  end

  it 'returns available swap memory in bytes' do
    result = Facter::Resolvers::Macosx::SwapMemory.resolve(:available_bytes)
    expect(result).to eq(available_bytes)
  end

  it 'returns total swap memory in bytes' do
    result = Facter::Resolvers::Macosx::SwapMemory.resolve(:total_bytes)
    expect(result).to eq(total_bytes)
  end

  it 'returns used swap memory in bytes' do
    result = Facter::Resolvers::Macosx::SwapMemory.resolve(:used_bytes)
    expect(result).to eq(used_bytes)
  end

  it 'returns capacity of swap memory' do
    result = Facter::Resolvers::Macosx::SwapMemory.resolve(:capacity)
    expect(result).to eq(capacity)
  end

  it 'returns true because swap memory is encrypted' do
    result = Facter::Resolvers::Macosx::SwapMemory.resolve(:encrypted)
    expect(result).to eq(encrypted)
  end
end
