# frozen_string_literal: true

describe Facts::Freebsd::Networking::Netmask6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Networking::Netmask6.new }

    let(:value) { 'ffff:ffff:ffff:ffff::' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:netmask6).and_return(value)
    end

    it 'returns the netmask6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.netmask6', value: value),
                        an_object_having_attributes(name: 'netmask6', value: value, type: :legacy))
    end

    context 'when netmask6 can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.netmask6', value: value),
                          an_object_having_attributes(name: 'netmask6', value: value, type: :legacy))
      end
    end
  end
end
