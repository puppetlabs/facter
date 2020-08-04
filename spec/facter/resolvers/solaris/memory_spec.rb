# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Memory do
  subject(:resolver) { Facter::Resolvers::Solaris::Memory }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('/usr/bin/kstat -m unix -n system_pages', logger: log_spy)
      .and_return(kstat_output)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('pagesize', logger: log_spy)
      .and_return(pagesize)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('/usr/sbin/swap -l', logger: log_spy)
      .and_return(swap_output)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when everything works fine' do
    let(:kstat_output) { load_fixture('kstat_sys_pages').read }
    let(:swap_output) { load_fixture('swap_l').read }
    let(:pagesize) { '4096' }

    it 'returns values for system' do
      expect(resolver.resolve(:system)).to eq(
        available_bytes: 2_627_383_296,
        capacity: '59.11%',
        total_bytes: 6_425_141_248,
        used_bytes: 3_797_757_952
      )
    end

    it 'returns values for swap' do
      expect(resolver.resolve(:swap)).to eq(
        available_bytes: 1_807_736_832,
        capacity: '0%',
        total_bytes: 1_807_736_832,
        used_bytes: 0
      )
    end
  end

  context 'when there is no output from kstat' do
    let(:kstat_output) { '' }
    let(:swap_output) { load_fixture('swap_l').read }
    let(:pagesize) { '4096' }

    it 'returns nil for system' do
      expect(resolver.resolve(:system)).to be_nil
    end

    it 'returns values for swap' do
      expect(resolver.resolve(:swap)).to eq(
        available_bytes: 1_807_736_832,
        capacity: '0%',
        total_bytes: 1_807_736_832,
        used_bytes: 0
      )
    end
  end

  context 'when there is no output from swap' do
    let(:kstat_output) { load_fixture('kstat_sys_pages').read }
    let(:swap_output) { '' }
    let(:pagesize) { '4096' }

    it 'returns values for system' do
      expect(resolver.resolve(:system)).to eq(
        available_bytes: 2_627_383_296,
        capacity: '59.11%',
        total_bytes: 6_425_141_248,
        used_bytes: 3_797_757_952
      )
    end

    it 'returns nil for swap' do
      expect(resolver.resolve(:swap)).to be_nil
    end
  end

  context 'when pagesize does not return a valid value' do
    let(:kstat_output) { load_fixture('kstat_sys_pages').read }
    let(:swap_output) { load_fixture('swap_l').read }
    let(:pagesize) { '-bash: pagesize: command not found' }

    it 'returns nil for system' do
      expect(resolver.resolve(:system)).to be_nil
    end

    it 'returns nil for swap' do
      expect(resolver.resolve(:swap)).to eq(
        available_bytes: 1_807_736_832,
        capacity: '0%',
        total_bytes: 1_807_736_832,
        used_bytes: 0
      )
    end
  end
end
