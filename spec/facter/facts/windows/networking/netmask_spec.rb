# frozen_string_literal: true

describe 'Windows NetworkingNetmask' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.netmask', value: 'value')
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:netmask).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.netmask', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingNetmask.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
