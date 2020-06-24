# frozen_string_literal: true

describe Facts::Aix::Networking::Network6 do
  subject(:fact) { Facts::Aix::Networking::Network6.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:network6).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { 'fe80::5989:97ff:75ae:dae7' }

    it 'calls Facter::Resolvers::Aix::Networking with network6' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:network6)
    end

    it 'returns network6 fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network6', value: value),
                        an_object_having_attributes(name: 'network6', value: value, type: :legacy))
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.network6', value: nil),
                        an_object_having_attributes(name: 'network6', value: nil, type: :legacy))
    end
  end
end
