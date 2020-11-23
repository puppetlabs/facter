# frozen_string_literal: true

describe Facter::Resolvers::Aix::Processors do
  subject(:resolver) { Facter::Resolvers::Aix::Processors }

  let(:odm_query_spy) { instance_spy(Facter::Util::Aix::ODMQuery) }
  let(:odm_query_spy2) { instance_spy(Facter::Util::Aix::ODMQuery) }
  let(:odm_query_spy3) { instance_spy(Facter::Util::Aix::ODMQuery) }
  let(:logger_spy) { instance_spy(Facter::Log) }

  before do
    resolver.instance_variable_set(:@log, logger_spy)
    allow(Facter::Util::Aix::ODMQuery).to receive(:new).and_return(odm_query_spy, odm_query_spy2, odm_query_spy3)
    allow(odm_query_spy).to receive(:equals).with('class', 'processor')
    allow(odm_query_spy).to receive(:execute).and_return(result)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when PdDv query fails' do
    let(:result) { nil }

    it 'returns nil' do
      expect(resolver.resolve(:speed)).to be_nil
    end
  end

  context 'when PdDv query succesful but CuDv fails' do
    let(:result) { load_fixture('processors_pddv').read }

    before do
      allow(odm_query_spy2).to receive(:equals).with('PdDvLn', 'processor/sys/proc_rspc')
      allow(odm_query_spy2).to receive(:execute).and_return(nil)
    end

    it 'returns nil' do
      expect(resolver.resolve(:speed)).to be_nil
    end
  end

  context 'when CuAt query fails' do
    let(:result) { load_fixture('processors_pddv').read }

    before do
      allow(odm_query_spy2).to receive(:equals).with('PdDvLn', 'processor/sys/proc_rspc')
      allow(odm_query_spy2).to receive(:execute).and_return(load_fixture('processors_cudv').read)

      allow(odm_query_spy3).to receive(:equals).with('name', 'proc0')
      allow(odm_query_spy3).to receive(:execute).and_return(nil)
    end

    it 'returns nil' do
      expect(resolver.resolve(:speed)).to be_nil
    end
  end

  context 'when all queries returns an output' do
    let(:result) { load_fixture('processors_pddv').read }
    let(:models) do
      %w[PowerPC_POWER8 PowerPC_POWER8 PowerPC_POWER8
         PowerPC_POWER8 PowerPC_POWER8 PowerPC_POWER8 PowerPC_POWER8 PowerPC_POWER8]
    end

    before do
      allow(odm_query_spy2).to receive(:equals).with('PdDvLn', 'processor/sys/proc_rspc')
      allow(odm_query_spy2).to receive(:execute).and_return(load_fixture('processors_cudv').read)

      allow(odm_query_spy3).to receive(:equals).with('name', 'proc0')
      allow(odm_query_spy3).to receive(:execute).and_return(load_fixture('processors_cuat').read)
    end

    it 'returns speed fact' do
      expect(resolver.resolve(:speed)).to eq(3_425_000_000)
    end

    it 'returns models fact' do
      expect(resolver.resolve(:models)).to eq(models)
    end

    it 'returns logical_count fact' do
      expect(resolver.resolve(:logical_count)).to eq(8)
    end
  end
end
