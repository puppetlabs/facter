# frozen_string_literal: true

describe Facts::Rhel::Lsbdistid do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Rhel::Lsbdistid.new }

    let(:value) { 'rhel' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:distributor_id)
    end

    it 'returns lsbdistid fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'lsbdistid', value: value, type: :legacy)
    end
  end
end
