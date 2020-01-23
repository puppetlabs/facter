# frozen_string_literal: true

describe 'Sles NetworkingFqdn' do
  context '#call_the_resolver' do
    let(:value) { 'host.domain' }
    subject(:fact) { Facter::Sles::NetworkingFqdn.new }

    before do
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:fqdn).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      expect(Facter::Resolvers::Hostname).to receive(:resolve).with(:fqdn)
      fact.call_the_resolver
    end

    it 'returns fqdn fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.fqdn', value: value),
                        an_object_having_attributes(name: 'fqdn', value: value, type: :legacy))
    end
  end
end
