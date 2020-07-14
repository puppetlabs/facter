# frozen_string_literal: true

describe Facts::Solaris::Networking::Ip6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Networking::Ip6.new }

    let(:value) { 'fe80::5989:97ff:75ae:dae7' }

    before do
      allow(Facter::Resolvers::Solaris::Networking).to receive(:resolve).with(:ip6).and_return(value)
    end

    it 'calls Facter::Resolvers::Solaris::Networking with ip6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Networking).to have_received(:resolve).with(:ip6)
    end

    it 'returns ipv6 address fact' do
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
