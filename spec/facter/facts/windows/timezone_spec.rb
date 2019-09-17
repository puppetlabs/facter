# frozen_string_literal: true

describe 'Windows Timezone' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'timezone', value: 'value')
      allow(Facter::Resolvers::TimezoneResolver).to receive(:resolve).with(:timezone).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('timezone', 'value').and_return(expected_fact)

      fact = Facter::Windows::Timezone.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
