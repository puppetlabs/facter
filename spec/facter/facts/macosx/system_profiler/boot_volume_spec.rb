# frozen_string_literal: true

describe 'Macosx SystemProfilerBootVolume' do
  context '#call_the_resolver' do
    let(:value) { 'Macintosh HD' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.boot_volume', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerBootVolume.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:boot_volume).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.boot_volume', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.boot_volume fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
