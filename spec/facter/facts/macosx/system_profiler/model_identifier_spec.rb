# frozen_string_literal: true

describe 'Macosx SystemProfilerModelIdentifier' do
  context '#call_the_resolver' do
    let(:value) { 'MacBookPro11,4' }
    let(:expected_resolved_fact) do
      double(Facter::ResolvedFact, name: 'system_profiler.model_identifier', value: value)
    end
    subject(:fact) { Facter::Macosx::SystemProfilerModelIdentifier.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:model_identifier).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.model_identifier', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.model_identifier fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
