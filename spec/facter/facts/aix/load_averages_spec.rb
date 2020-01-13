# frozen_string_literal: true

describe 'Aix LoadAverages' do
  context '#call_the_resolver' do
    let(:value) { { '1m' => 0.01, '5m' => 0.02, '15m' => 0.03 } }
    let(:expected_resolved_fact) { double(Facter::ResolvedFact, name: 'load_averages', value: value) }
    subject(:fact) { Facter::Aix::LoadAverages.new }

    before do
      expect(Facter::Resolvers::Aix::LoadAverages).to receive(:resolve).with(:load_averages).and_return(value)
      expect(Facter::ResolvedFact).to receive(:new).with('load_averages', value).and_return(expected_resolved_fact)
    end

    it 'returns load_averages fact' do
      expect(fact.call_the_resolver).to eq(expected_resolved_fact)
    end
  end
end
