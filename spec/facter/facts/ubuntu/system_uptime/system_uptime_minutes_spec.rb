# frozen_string_literal: true

describe 'Ubuntu SystemUptimeMinutes' do
  context '#call_the_resolver' do
    let(:value) { { minutes: 3600 } }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'system_uptime.minutes', value: value)
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:minutes).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('system_uptime.minutes', value).and_return(expected_fact)

      fact = Facter::Ubuntu::SystemUptimeMinutes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
