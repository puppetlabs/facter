# frozen_string_literal: true

describe 'Macosx SystemProfilerSerialNumber' do
  context '#call_the_resolver' do
    let(:value) { 'C02WW1LAG8WL' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.serial_number', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerSerialNumber.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:serial_number).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.serial_number', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.serial_number fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
