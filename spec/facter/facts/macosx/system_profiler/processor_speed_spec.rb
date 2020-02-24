# frozen_string_literal: true

describe Facter::Macosx::SystemProfilerProcessorSpeed do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::SystemProfilerProcessorSpeed.new }

    let(:value) { '2.8 GHz' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.processor_speed', value: value) }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:processor_speed).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.processor_speed', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.processor_speed fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
