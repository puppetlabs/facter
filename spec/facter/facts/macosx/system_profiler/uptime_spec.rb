# frozen_string_literal: true

describe 'Macosx SystemProfilerUptime' do
  context '#call_the_resolver' do
    let(:value) { '26 days 22:12' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.uptime', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerUptime.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:uptime).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.uptime', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.uptime fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
