# frozen_string_literal: true

describe 'Macosx SystemProfilerSystemVersion' do
  context '#call_the_resolver' do
    let(:value) { 'macOS 10.14.6 (18G95)' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.system_version', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerSystemVersion.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:system_version).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.system_version', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.system_version fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
