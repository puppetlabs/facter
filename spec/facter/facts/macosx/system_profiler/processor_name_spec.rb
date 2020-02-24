# frozen_string_literal: true

describe Facter::Macosx::SystemProfilerProcessorName do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::SystemProfilerProcessorName.new }

    let(:value) { 'Intel Core i7' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.processor_name', value: value) }

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
