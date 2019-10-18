# frozen_string_literal: true

describe 'Windows NetworkingIp' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.ip', value: 'value')
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:ip).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.ip', 'value').and_return(expected_fact)

      fact = Facter::Windows::NetworkingIp.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
