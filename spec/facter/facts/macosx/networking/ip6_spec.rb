# frozen_string_literal: true

describe Facts::Macosx::Networking::Ip6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Ip6.new }

    let(:value) { 'fe80::2cba:e4ff:fe83:4bb7' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:ip6).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking with :ip6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:ip6)
    end

    it 'returns the ip6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip6', value: value),
                        an_object_having_attributes(name: 'ipaddress6', value: value, type: :legacy))
    end

    context 'when ip6 can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.ip6', value: value),
                          an_object_having_attributes(name: 'ipaddress6', value: value, type: :legacy))
      end
    end
  end
end
