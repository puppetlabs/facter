# frozen_string_literal: true

describe 'Windows SystemUptimeDays' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'system_uptime.days', value: 'value')
      allow(Facter::Resolvers::Windows::Uptime).to receive(:resolve).with(:days).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('system_uptime.days', 'value').and_return(expected_fact)

      fact = Facter::Windows::SystemUptimeDays.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
