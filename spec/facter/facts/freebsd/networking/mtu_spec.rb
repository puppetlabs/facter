# frozen_string_literal: true

describe Facts::Freebsd::Networking::Mtu do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Networking::Mtu.new }

    let(:value) { 1500 }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:mtu).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking with :mtu' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:mtu)
    end

    it 'returns mtu fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.mtu', value: value)
    end

    context 'when mtu can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.mtu', value: value)
      end
    end
  end
end
