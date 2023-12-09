# frozen_string_literal: true

describe Facts::Solaris::LoadAverages do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::LoadAverages.new }

    let(:value) { { '1m' => 0.01, '5m' => 0.02, '15m' => 0.03 } }

    before do
      allow(Facter::Resolvers::LoadAverages).to receive(:resolve).with(:load_averages).and_return(value)
    end

    it 'returns load_averages fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'load_averages', value: value)
    end
  end
end
