# frozen_string_literal: true

describe Facter::Resolvers::Aix::Partitions do
  subject(:resolver) { Facter::Resolvers::Aix::Partitions }

  let(:odm_query_spy) { instance_spy(Facter::ODMQuery) }
  let(:logger_spy) { instance_spy(Facter::Log) }

  before do
    resolver.instance_variable_set(:@log, logger_spy)
    allow(Facter::ODMQuery).to receive(:new).and_return(odm_query_spy)
    allow(odm_query_spy).to receive(:equals).with('PdDvLn', 'logical_volume/lvsubclass/lvtype')
    allow(odm_query_spy).to receive(:execute).and_return(result)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when retrieving partitions name fails' do
    let(:result) { nil }

    before do
      allow(odm_query_spy).to receive(:execute).and_return(result)
    end

    it 'returns nil' do
      expect(resolver.resolve(:partitions)).to be_nil
    end
  end

  context 'when CuDv query succesful' do
    let(:result) { load_fixture('partitions_cudv_query').read }

    let(:partitions) do
      { '/dev/hd5' => { filesystem: 'boot', label: 'primary_bootlv', size: '32.00 MiB', size_bytes: 33_554_432 } }
    end

    before do
      allow(Open3).to receive(:capture3).with('lslv -L hd5').and_return(load_fixture('lslv_output').read)
      allow(Open3).to receive(:capture3).with('lslv -L hd6').and_return(['', 'Error: something happened!', 1])
    end

    it 'returns partitions informations' do
      expect(resolver.resolve(:partitions)).to eql(partitions)
    end

    it 'logs stderr output in case lslv commands fails' do
      resolver.resolve(:partitions)

      expect(logger_spy).to have_received(:debug).with('Error: something happened!')
    end
  end
end
