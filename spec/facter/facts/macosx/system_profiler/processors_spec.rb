# frozen_string_literal: true

describe 'Macosx SystemProfilerProcessors' do
  context '#call_the_resolver' do
    let(:value) { '1' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.processors', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerProcessors.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:processors).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.processors', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.processors fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
