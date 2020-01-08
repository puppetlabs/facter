# frozen_string_literal: true

describe 'Macosx SystemProfilerProcessorName' do
  context '#call_the_resolver' do
    let(:value) { 'Intel Core i7' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.processor_name', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerProcessorName.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:processor_name).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.processor_name', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.processor_name fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
