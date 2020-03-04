# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::BootVolume do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::BootVolume.new }

    let(:value) { 'Macintosh HD' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.boot_volume', value: value) }

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
