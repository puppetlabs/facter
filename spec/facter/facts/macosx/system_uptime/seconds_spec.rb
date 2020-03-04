# frozen_string_literal: true

describe Facts::Macosx::SystemUptime::Seconds do
  describe '#call_the_resolver' do
    let(:value) { '123094' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'system_uptime.seconds', value: value)
      allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:seconds).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('system_uptime.seconds', value).and_return(expected_fact)

      fact = Facts::Macosx::SystemUptime::Seconds.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
