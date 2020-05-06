# frozen_string_literal: true

describe Facts::Linux::Networking::Domain do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Domain.new }

    let(:value) { 'domain' }

    before do
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:domain).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Hostname).to have_received(:resolve).with(:domain)
    end

    it 'returns domain fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.domain', value: value),
                        an_object_having_attributes(name: 'domain', value: value, type: :legacy))
    end
  end
end
