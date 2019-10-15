# frozen_string_literal: true

describe 'Fedora SystemUptimeHours' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = '4'

      expected_fact = double(Facter::ResolvedFact, name: 'system_uptime.hours', value: value)
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:hours).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('system_uptime.hours', value).and_return(expected_fact)

      fact = Facter::Fedora::SystemUptimeHours.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
