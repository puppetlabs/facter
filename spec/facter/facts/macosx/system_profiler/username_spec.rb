# frozen_string_literal: true

describe 'Macosx SystemProfilerUsername' do
  context '#call_the_resolver' do
    let(:value) { 'Test1 Test2 (test1.test2)' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.username', value: value) }
    subject(:fact) { Facter::Macosx::SystemProfilerUsername.new }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:user_name).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.username', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.username fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
