# frozen_string_literal: true

describe Facter::Resolvers::Macosx::SwapMemory do
  subject(:swap_memory) { Facter::Resolvers::Macosx::SwapMemory }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:available_bytes) { 1_729_363_968 }
  let(:total_bytes) { 3_221_225_472 }
  let(:used_bytes) { 1_491_861_504 }
  let(:capacity) { '46.31%' }
  let(:encrypted) { true }

  before do
    swap_memory.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('sysctl -n vm.swapusage', logger: log_spy)
      .and_return('total = 3072.00M  used = 1422.75M  free = 1649.25M  (encrypted)')
  end

  it 'returns available swap memory in bytes' do
    expect(swap_memory.resolve(:available_bytes)).to eq(available_bytes)
  end

  it 'returns total swap memory in bytes' do
    expect(swap_memory.resolve(:total_bytes)).to eq(total_bytes)
  end

  it 'returns used swap memory in bytes' do
    expect(swap_memory.resolve(:used_bytes)).to eq(used_bytes)
  end

  it 'returns capacity of swap memory' do
    expect(swap_memory.resolve(:capacity)).to eq(capacity)
  end

  it 'returns true because swap memory is encrypted' do
    expect(swap_memory.resolve(:encrypted)).to eq(encrypted)
  end
end
