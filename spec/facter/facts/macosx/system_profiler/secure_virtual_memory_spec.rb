# frozen_string_literal: true

describe 'Macosx SystemProfilerSecureVirtualMemory' do
  context '#call_the_resolver' do
    let(:value) { 'Enabled' }
    let(:expected_resolved_fact) do
      double(Facter::ResolvedFact, name: 'system_profiler.secure_virtual_memory', value: value)
    end
    subject(:fact) { Facter::Macosx::SystemProfilerSecureVirtualMemory.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:secure_virtual_memory).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.secure_virtual_memory', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.secure_virtual_memory fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
