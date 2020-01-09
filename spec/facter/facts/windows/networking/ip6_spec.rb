# frozen_string_literal: true

describe 'Windows NetworkingIp6' do
  context '#call_the_resolver' do
    let(:value) { 'fe80::5989:97ff:75ae:dae7' }
    subject(:fact) { Facter::Windows::NetworkingIp6.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:ip6).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:ip6)
      fact.call_the_resolver
    end

    it 'returns ipv6 address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip6', value: value),
                        an_object_having_attributes(name: 'ipaddress6', value: value, type: :legacy))
    end
  end
end
