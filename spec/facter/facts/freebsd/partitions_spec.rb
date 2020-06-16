# frozen_string_literal: true

describe Facts::Freebsd::Partitions do
  subject(:fact) { Facts::Freebsd::Partitions.new }

  let(:partitions) do
    {
      'ada0p1' => {
        'partlabel' => 'gptboot0',
        'partuuid' => '503d3458-c135-11e8-bd11-7d7cd061b26f',
        'size' => '512.00 KiB',
        'size_bytes' => 524_288
      }
    }
  end

  describe '#call_the_resolver' do
    before do
      allow(Facter::Resolvers::Freebsd::Geom).to receive(:resolve).with(:partitions).and_return(partitions)
    end

    it 'calls Facter::Resolvers::Freebsd::Partitions' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Freebsd::Geom).to have_received(:resolve).with(:partitions)
    end

    it 'returns resolved fact with name partitions and value' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'partitions', value: partitions)
    end
  end
end
