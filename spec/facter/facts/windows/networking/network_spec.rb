# frozen_string_literal: true

describe Facts::Windows::Networking::Network do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Network.new }

    let(:value) { '10.16.112.0' }

    before do
      allow(Facter::Resolvers::Windows::Networking).to receive(:resolve).with(:network).and_return(value)
    end

    it 'calls Facter::Resolvers::Windows::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Windows::Networking).to have_received(:resolve).with(:network)
    end

    it 'returns network ipv4 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network', value: value),
                        an_object_having_attributes(name: 'network', value: value, type: :legacy))
    end
  end
end
