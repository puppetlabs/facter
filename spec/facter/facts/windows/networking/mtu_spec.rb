# frozen_string_literal: true

describe 'Windows NetworkingMtu' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.mtu', value: 'value')
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:mtu).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.mtu', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingMtu.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
