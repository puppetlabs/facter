# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Processors do
  subject(:resolver) { Facter::Resolvers::Solaris::Processors }

  before do
    allow(File).to receive(:executable?).with('/usr/bin/kstat').and_return(status)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('/usr/bin/kstat -m cpu_info', logger: resolver.log)
      .and_return(output)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when kstat is present and can retrieve information' do
    let(:logicalcount) { 2 }
    let(:models) do
      ['Intel(r) Xeon(r) Gold 6138 CPU @ 2.00GHz', 'Intel(r) Xeon(r) Gold 6138 CPU @ 2.00GHz']
    end
    let(:physical_processors) { 2 }
    let(:speed_expected) { 1_995_246_617 }
    let(:output) { load_fixture('kstat_cpu').read }
    let(:status) { true }

    it 'returns number of processors' do
      expect(resolver.resolve(:logical_count)).to eq(logicalcount)
    end

    it 'returns number of physical processors' do
      expect(resolver.resolve(:physical_count)).to eq(physical_processors)
    end

    it 'returns list of models' do
      expect(resolver.resolve(:models)).to eq(models)
    end

    it 'returns speed of processors' do
      expect(resolver.resolve(:speed)).to eq(speed_expected)
    end
  end

  context 'when kstat is not present' do
    let(:output) { '' }
    let(:status) { false }

    it 'returns nil' do
      expect(resolver.resolve(:models)).to be_nil
    end
  end

  context 'when kstat is present but fails' do
    let(:output) { '' }
    let(:status) { true }

    it 'returns nil' do
      expect(resolver.resolve(:models)).to be_nil
    end
  end
end
