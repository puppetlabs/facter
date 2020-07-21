# frozen_string_literal: true

describe Facts::Aix::Disks do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Disks.new }

    let(:disk) do
      {
        'disks' => {
          'hdisk0' => {
            'size' => '20.00 GiB',
            'size_bytes' => 21_474_836_480
          }
        }
      }
    end

    before do
      allow(Facter::Resolvers::Aix::Disks).to receive(:resolve).with(:disks).and_return(disk)
    end

    it 'calls Facter::Resolvers::Aix::Disk' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Disks).to have_received(:resolve).with(:disks)
    end

    it 'returns resolved fact with name disk and value' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'disks', value: disk)
    end

    context 'when resolver returns empty hash' do
      let(:disk) { {} }

      it 'returns nil fact' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'disks', value: nil)
      end
    end

    context 'when resolver returns nil' do
      let(:disk) { nil }

      it 'returns nil fact' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'disks', value: nil)
      end
    end
  end
end
