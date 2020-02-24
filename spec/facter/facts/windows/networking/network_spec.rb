# frozen_string_literal: true

describe Facter::Windows::NetworkingNetwork do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::NetworkingNetwork.new }

    let(:value) { '10.16.112.0' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:network).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Networking).to receive(:resolve).with(:network)
      fact.call_the_resolver
    end

    it 'returns network ipv4 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network', value: value),
                        an_object_having_attributes(name: 'network', value: value, type: :legacy))
    end
  end
end
