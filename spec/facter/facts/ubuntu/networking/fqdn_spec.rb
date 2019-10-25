# frozen_string_literal: true

describe 'Ubuntu NetworkingFqdn' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.fqdn', value: 'test.test.com')
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return('test')
      allow(Facter::Resolvers::NetworkingDomain).to receive(:resolve).with(:networking_domain).and_return('test.com')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.fqdn', 'test.test.com').and_return(expected_fact)

      fact = Facter::Ubuntu::NetworkingFqdn.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
