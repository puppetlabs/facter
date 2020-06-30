# frozen_string_literal: true

describe Facts::Aix::Networking::Mtu do
  subject(:fact) { Facts::Aix::Networking::Mtu.new }

  before do
    allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:mtu).and_return(value)
  end

  describe '#call_the_resolver' do
    let(:value) { 1500 }

    it 'calls Facter::Resolvers::Aix::Networking with mtu' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Networking).to have_received(:resolve).with(:mtu)
    end

    it 'returns mtu fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.mtu', value: value)
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:value) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.mtu', value: nil)
    end
  end
end
