# frozen_string_literal: true

describe 'Windows NetworkingNetmask6' do
  context '#call_the_resolver' do
    let(:value) { 'ffff:ffff:ffff:ffff::' }
    subject(:fact) { Facter::Windows::NetworkingNetmask6.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:netmask6).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:netmask6)
      fact.call_the_resolver
    end

    it 'returns netmask for ipv6 ip address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.netmask6', value: value),
                        an_object_having_attributes(name: 'netmask6', value: value, type: :legacy))
    end
  end
end
