# frozen_string_literal: true

describe Facter::Resolvers::Freebsd::SystemMemory do
  subject(:system_memory) { Facter::Resolvers::Freebsd::SystemMemory }

  let(:log_spy) { instance_spy(Facter::Log) }
  let(:available_bytes) { 2_696_462_336 }
  let(:total_bytes) { 17_043_554_304 }
  let(:used_bytes) { 14_347_091_968 }
  let(:capacity) { '84.18%' }

  before do
    system_memory.instance_variable_set(:@log, log_spy)
    allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name)
      .with(:long, 'vm.stats.vm.v_page_size')
      .and_return(4096)
    allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name)
      .with(:long, 'vm.stats.vm.v_page_count')
      .and_return(4_161_024)
    allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name)
      .with(:long, 'vm.stats.vm.v_active_count')
      .and_return(2_335_139)
    allow(Facter::Freebsd::FfiHelper).to receive(:sysctl_by_name)
      .with(:long, 'vm.stats.vm.v_wire_count')
      .and_return(1_167_569)
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
