# frozen_string_literal: true

describe Facts::Macosx::SystemProfiler::Cores do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemProfiler::Cores.new }

    let(:value) { '' }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'system_profiler.cores', value: value) }

    before do
      expect(Facter::Resolvers::SystemProfiler).to receive(:resolve).with(:total_number_of_cores).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new)
        .with('system_profiler.cores', value)
        .and_return(expected_resolved_fact)
    end

    it 'returns system_profiler.cores fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
