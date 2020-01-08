# frozen_string_literal: true

describe 'Macosx SystemProfilerL2CachePerCore' do
  context '#call_the_resolver' do
    let(:value) { '256 KB' }
    let(:expected_resolved_fact) do
      double(Facter::ResolvedFact, name: 'system_profiler.l2_cache_per_core', value: value)
    end
    subject(:fact) { Facter::Macosx::SystemProfilerL2CachePerCore.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:l2_cache_per_core).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.l2_cache_per_core', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.l2_cache_per_core fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
