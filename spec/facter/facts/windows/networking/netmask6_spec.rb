# frozen_string_literal: true

describe Facts::Windows::Networking::Netmask6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Netmask6.new }

    let(:value) { 'ffff:ffff:ffff:ffff::' }

    before do
      allow(Facter::Resolvers::Windows::Networking).to receive(:resolve).with(:netmask6).and_return(value)
    end

    it 'calls Facter::Resolvers::Windows::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Windows::Networking).to have_received(:resolve).with(:netmask6)
    end

    it 'returns netmask for ipv6 ip address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.netmask6', value: value),
                        an_object_having_attributes(name: 'netmask6', value: value, type: :legacy))
    end
  end
end
