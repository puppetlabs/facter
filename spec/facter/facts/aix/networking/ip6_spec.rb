# frozen_string_literal: true

describe Facts::Aix::Networking::Ip6 do
  subject(:fact) { Facts::Aix::Networking::Ip6.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:ip6).and_return(ip6)
  end

  describe '#call_the_resolver' do
    let(:ip6) { 'fe80::5989:97ff:75ae:dae7' }

    it 'calls Facter::Resolvers::Aix::Networking with ip6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:ip6)
    end

    it 'returns ipv6 address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip6', value: ip6),
                        an_object_having_attributes(name: 'ipaddress6', value: ip6, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:ip6) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip6', value: nil),
                        an_object_having_attributes(name: 'ipaddress6', value: nil, type: :legacy))
    end
  end
end
