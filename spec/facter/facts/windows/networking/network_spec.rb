# frozen_string_literal: true

describe 'Windows NetworkingNetwork' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.network', value: 'value')
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:network).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.network', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingNetwork.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
