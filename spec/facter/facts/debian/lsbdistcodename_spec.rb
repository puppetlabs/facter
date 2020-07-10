# frozen_string_literal: true

describe Facts::Debian::Lsbdistcodename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Lsbdistcodename.new }

    let(:value) { 'stretch' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:codename).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:codename)
    end

    it 'returns lsbdistcodename fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'lsbdistcodename', value: value, type: :legacy)
    end
  end
end
