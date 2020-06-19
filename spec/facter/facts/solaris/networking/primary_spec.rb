# frozen_string_literal: true

describe Facts::Solaris::Networking::Primary do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Networking::Primary.new }

    let(:value) { 'ens160' }

    before do
      allow(Facter::Resolvers::Solaris::Networking).to receive(:resolve).with(:primary_interface).and_return(value)
    end

    it 'calls Facter::Resolvers::Solaris::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::Networking).to have_received(:resolve).with(:primary_interface)
    end

    it 'returns networking.primary fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.primary', value: value)
    end

    context 'when primary interface can not be retrieved' do
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.primary', value: value)
      end
    end
  end
end
