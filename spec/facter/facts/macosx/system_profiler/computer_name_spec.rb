# frozen_string_literal: true

describe Facter::Macosx::SystemProfilerComputerName do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Macosx::SystemProfilerComputerName.new }

    let(:value) { 'Test1’s MacBook Pro' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.computer_name', value: value) }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:computer_name).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.computer_name', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.computer_name fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
