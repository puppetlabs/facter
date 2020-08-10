# frozen_string_literal: true

describe Facter::Resolvers::Freebsd::SwapMemory do
  subject(:swap_memory) { Facter::Resolvers::Freebsd::SwapMemory }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:available_bytes) { 4_294_967_296 }
  let(:total_bytes) { 4_294_967_296 }
  let(:used_bytes) { 0 }
  let(:capacity) { '0.00%' }
  let(:encrypted) { true }

  before do
    swap_memory.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('swapinfo -k', logger: log_spy)
      .and_return(load_fixture('freebsd_swapinfo').read)
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
