# frozen_string_literal: true

describe Facts::Freebsd::Networking::Netmask do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Networking::Netmask.new }

    let(:value) { '255.255.255.0' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:netmask).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking with :netmask' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:netmask)
    end

    it 'returns the netmask fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.netmask', value: value),
                        an_object_having_attributes(name: 'netmask', value: value, type: :legacy))
    end

    context 'when netmask can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.netmask', value: value),
                          an_object_having_attributes(name: 'netmask', value: value, type: :legacy))
      end
    end
  end
end
