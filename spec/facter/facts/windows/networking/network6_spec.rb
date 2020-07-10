# frozen_string_literal: true

describe Facts::Windows::Networking::Network6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Network6.new }

    let(:value) { 'fe80::' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:network6).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:network6)
    end

    it 'returns network ipv6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network6', value: value),
                        an_object_having_attributes(name: 'network6', value: value, type: :legacy))
    end
  end
end
