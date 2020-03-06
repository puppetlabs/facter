# frozen_string_literal: true

describe Facts::El::Timezone do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Timezone.new }

    let(:timezone) { 'UTC' }

    before do
      allow(Facter::Resolvers::Timezone).to \
        receive(:resolve).with(:timezone).and_return(timezone)
    end

    it 'calls Facter::Resolvers::Timezone' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Timezone).to have_received(:resolve).with(:timezone)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'timezone', value: timezone)
    end
  end
end
