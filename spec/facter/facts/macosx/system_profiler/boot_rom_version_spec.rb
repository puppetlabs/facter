# frozen_string_literal: true

describe Facter::Macosx::SystemProfilerBootRomVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::SystemProfilerBootRomVersion.new }

    let(:value) { '194.0.0.0.0' }
    let(:expected_resolved_fact) do
      double(Facter::ResolvedFact, name: 'system_profiler.boot_rom_version', value: value)
    end

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:boot_rom_version).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.boot_rom_version', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.boot_rom_version fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
