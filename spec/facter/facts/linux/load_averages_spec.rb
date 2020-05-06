# frozen_string_literal: true

describe Facts::Linux::LoadAverages do
  subject(:fact) { Facts::Linux::LoadAverages.new }

  let(:averages) do
    {
      '15m' => 0.0,
      '10m' => 0.0,
      '5m' => 0.0
    }
  end

  describe '#call_the_resolver' do
    before do
      allow(Facter::Resolvers::Linux::LoadAverages).to receive(:resolve).with(:load_averages).and_return(averages)
    end

    it 'calls Facter::Resolvers::Linux::LoadAverages' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::LoadAverages).to have_received(:resolve).with(:load_averages)
    end

    it 'returns resolved fact with name disk and value' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'load_averages', value: averages)
    end
  end
end
