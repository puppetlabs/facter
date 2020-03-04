# frozen_string_literal: true

describe Facts::Aix::LoadAverages do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::LoadAverages.new }

    let(:value) { { '1m' => 0.01, '5m' => 0.02, '15m' => 0.03 } }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'load_averages', value: value) }

    before do
      expect(Facter::Resolvers::Aix::LoadAverages).to receive(:resolve).with(:load_averages).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('load_averages', value).and_return(expected_resolved_fact)
    end

    it 'returns load_averages fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
