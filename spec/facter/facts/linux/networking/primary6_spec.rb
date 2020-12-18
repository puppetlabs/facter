# frozen_string_literal: true

describe Facts::Linux::Networking::Primary6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Primary6.new }

    let(:value) { 'ens160' }

    before do
      allow(Facter::Resolvers::Linux::Networking).to receive(:resolve).with(:primary6_interface).and_return(value)
    end

    it 'calls Facter::Resolvers::Linux::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::Networking).to have_received(:resolve).with(:primary6_interface)
    end

    it 'returns networking.primary6 fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.primary6', value: value)
    end

    context 'when primary6 interface can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.primary6', value: value)
      end
    end
  end
end
