# frozen_string_literal: true

describe Facter::Resolvers::Aix::Memory do
  subject(:resolver) { Facter::Resolvers::Aix::Memory }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute).with('svmon', logger: log_spy)
                                                       .and_return(svmon_content)
    allow(Facter::Core::Execution).to receive(:execute).with('pagesize', logger: log_spy)
                                                       .and_return(pagesize_content)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when svmon call fails' do
    let(:svmon_content) { '' }
    let(:pagesize_content) { '' }

    it 'returns nil for system' do
      expect(resolver.resolve(:system)).to be_nil
    end

    it 'returns nil for swap' do
      expect(resolver.resolve(:swap)).to be_nil
    end
  end

  context 'when pagesize call fails' do
    let(:svmon_content) { load_fixture('svmon_content').read }
    let(:pagesize_content) { '' }

    it 'returns nil for system' do
      expect(resolver.resolve(:system)).to be_nil
    end

    it 'returns nil for swap' do
      expect(resolver.resolve(:swap)).to be_nil
    end
  end

  context 'when svmon returns invalid content' do
    let(:svmon_content) { 'some_errors_on_stdout' }
    let(:pagesize_content) { '4096' }

    it 'returns empty hash for system' do
      expect(resolver.resolve(:system)).to be_a(Hash).and contain_exactly
    end

    it 'returns empty hash for swap' do
      expect(resolver.resolve(:swap)).to be_a(Hash).and contain_exactly
    end
  end

  context 'when all calls return valid content' do
    let(:svmon_content) { load_fixture('svmon_content').read }
    let(:pagesize_content) { '4096' }

    let(:system_memory) do
      { available_bytes: 4_966_027_264, capacity: '42.19%', total_bytes: 8_589_934_592, used_bytes: 3_623_907_328 }
    end

    let(:swap_memory) do
      { available_bytes: 525_660_160, capacity: '2.09%', total_bytes: 536_870_912, used_bytes: 11_210_752 }
    end

    it 'returns facts for system memory' do
      expect(resolver.resolve(:system)).to eq(system_memory)
    end

    it 'returns facts for swap memory' do
      expect(resolver.resolve(:swap)).to eq(swap_memory)
    end
  end
end
