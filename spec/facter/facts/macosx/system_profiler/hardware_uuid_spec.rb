# frozen_string_literal: true

describe 'Macosx SystemProfilerHardwareUuid' do
  context '#call_the_resolver' do
    let(:value) { '7C3B701F-B88A-56C6-83F4-ACBD450075C4' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.hardware_uuid', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerHardwareUuid.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:hardware_uuid).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.hardware_uuid', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.hardware_uuid fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
