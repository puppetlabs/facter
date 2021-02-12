# frozen_string_literal: true

describe Facts::Sles::Lsbdistdescription do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Lsbdistdescription.new }

    let(:value) { 'sles' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:description).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:description)
    end

    it 'returns lsbdistdescription fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'lsbdistdescription', value: value, type: :legacy)
    end
  end
end
