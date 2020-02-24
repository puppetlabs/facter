# frozen_string_literal: true

describe Facter::Macosx::SystemProfilerMemory do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::SystemProfilerMemory.new }

    let(:value) { '16 GB' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.memory', value: value) }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:memory).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.memory', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.memory fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
