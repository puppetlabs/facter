# frozen_string_literal: true

describe Facts::Freebsd::Networking::Primary do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Networking::Primary.new }

    let(:value) { 'en0' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:primary_interface).and_return(value)
    end

    it 'returns networking.primary fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.primary', value: value)
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
