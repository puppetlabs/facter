# frozen_string_literal: true

describe Facter::Macosx::SystemProfilerBootMode do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::SystemProfilerBootMode.new }

    let(:value) { 'Normal' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.boot_mode', value: value) }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:boot_mode).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.boot_mode', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.boot_mode fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
