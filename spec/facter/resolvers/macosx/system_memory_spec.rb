# frozen_string_literal: true

describe Facter::Resolvers::Macosx::SystemMemory do
  subject(:system_memory) { Facter::Resolvers::Macosx::SystemMemory }

  let(:available_bytes) { 5_590_519_808 }
  let(:total_bytes) { 34_359_738_368 }
  let(:used_bytes) { 28_769_218_560 }
  let(:capacity) { '83.73%' }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('sysctl -n hw.memsize', logger: an_instance_of(Facter::Log))
      .and_return('34359738368')

    allow(Facter::Core::Execution).to receive(:execute)
      .with('vm_stat', logger: an_instance_of(Facter::Log))
      .and_return(load_fixture('vm_stat').read)
  end

  it 'returns available system memory in bytes' do
    expect(system_memory.resolve(:available_bytes)).to eq(available_bytes)
  end

  it 'returns total system memory in bytes' do
    expect(system_memory.resolve(:total_bytes)).to eq(total_bytes)
  end

  it 'returns used system memory in bytes' do
    expect(system_memory.resolve(:used_bytes)).to eq(used_bytes)
  end

  it 'returns memory capacity' do
    expect(system_memory.resolve(:capacity)).to eq(capacity)
  end
end
