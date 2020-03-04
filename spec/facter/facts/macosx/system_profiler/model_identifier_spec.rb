# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::ModelIdentifier do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::ModelIdentifier.new }

    let(:value) { 'MacBookPro11,4' }
    let(:expected_resolved_fact) do
      double(Facter::ResolvedFact, name: 'system_profiler.model_identifier', value: value)
    end

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
