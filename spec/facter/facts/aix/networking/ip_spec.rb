# frozen_string_literal: true

describe 'Aix NetworkingIp' do
  context '#call_the_resolver' do
    let(:value) { '0.16.121.255' }
    subject(:fact) { Facter::Aix::NetworkingIp.new }

    before do
      allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:ip).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:ip)
      fact.call_the_resolver
    end

    it 'returns ipv4 address fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.ip', value: value),
                        an_object_having_attributes(name: 'ipaddress', value: value, type: :legacy))
    end
  end
end
