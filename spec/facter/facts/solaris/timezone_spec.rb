# frozen_string_literal: true

describe Facts::Solaris::Timezone do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::Timezone.new }

    let(:timezone) { 'UTC' }

    before do
      allow(Facter::Resolvers::Timezone).to \
        receive(:resolve).with(:timezone).and_return(timezone)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'timezone', value: timezone)
    end
  end
end
