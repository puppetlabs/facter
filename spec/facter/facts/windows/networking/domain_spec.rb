# frozen_string_literal: true

describe Facter::Windows::NetworkingDomain do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::NetworkingDomain.new }

    let(:value) { 'domain.net' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:domain).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:domain)
      fact.call_the_resolver
    end

    it 'returns domain fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.domain', value: value),
                        an_object_having_attributes(name: 'domain', value: value, type: :legacy))
    end
  end
end
