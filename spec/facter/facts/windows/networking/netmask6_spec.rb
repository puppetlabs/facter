# frozen_string_literal: true

describe 'Windows NetworkingNetmask6' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.netmask6', value: 'value')
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:netmask6).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.netmask6', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingNetmask6.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
