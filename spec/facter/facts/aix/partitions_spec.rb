# frozen_string_literal: true

describe Facts::Aix::Partitions do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Partitions.new }

    let(:value) do
      { '/dev/hd5' => { 'filesystem' => 'boot',
                        'size_bytes' => 33_554_432,
                        'size' => '32.00 MiB',
                        'label' => 'primary_bootlv' } }
    end

    before do
      allow(Facter::Resolvers::Aix::Partitions).to receive(:resolve).with(:partitions).and_return(value)
    end

    it 'calls Facter::Resolvers::Aix::Partitions' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Partitions).to have_received(:resolve).with(:partitions)
    end

    it 'returns partitions fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'partitions', value: value)
    end
  end
end
