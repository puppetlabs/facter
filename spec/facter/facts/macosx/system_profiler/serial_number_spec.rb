# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::SerialNumber.new }

    let(:value) { 'C02WW1LAG8WL' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.serial_number', value: value) }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:serial_number_system).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.serial_number', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.serial_number fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
