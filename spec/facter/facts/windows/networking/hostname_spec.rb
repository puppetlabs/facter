# frozen_string_literal: true

describe 'Windows NetworkingHostname' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.hostname', value: 'value')
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.hostname', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingHostname.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
