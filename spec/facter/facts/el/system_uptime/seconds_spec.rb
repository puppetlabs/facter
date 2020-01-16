# frozen_string_literal: true

describe 'Fedora SystemUptimeSeconds' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = '16059'

      expected_fact = double(Facter::ResolvedFact, name: 'system_uptime.seconds', value: value)
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:seconds).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('system_uptime.seconds', value).and_return(expected_fact)

      fact = Facter::El::SystemUptimeSeconds.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
