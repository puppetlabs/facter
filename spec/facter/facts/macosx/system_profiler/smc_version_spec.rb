# frozen_string_literal: true

describe 'Macosx SystemProfilerSmcVersion' do
  context '#call_the_resolver' do
    let(:value) { '2.29f24' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.smc_version', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerSmcVersion.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:smc_version).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.smc_version', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.smc_version fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
