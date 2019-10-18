# frozen_string_literal: true

describe 'Windows NetworkingMac' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.mac', value: 'value')
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:mac).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.mac', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingMac.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
