# frozen_string_literal: true

describe 'Windows NetworkingFqdn' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.fqdn', value: 'hostname.domain')
      allow(Facter::Resolvers::Domain).to receive(:resolve).with(:domain).and_return('domain')
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return('hostname')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.fqdn', 'hostname.domain').and_return(expected_fact)

      fact = Facter::Windows::NetworkingFqdn.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'returns a fact when fails to retrieve hostname' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.fqdn', value: nil)
      allow(Facter::Resolvers::Domain).to receive(:resolve).with(:domain).and_return('domain')
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return(nil)
      allow(Facter::ResolvedFact).to receive(:new).with('networking.fqdn', nil).and_return(expected_fact)

      fact = Facter::Windows::NetworkingFqdn.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'returns a fact when fails to retrieve domain' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.fqdn', value: 'hostname')
      allow(Facter::Resolvers::Domain).to receive(:resolve).with(:domain).and_return(nil)
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return('hostname')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.fqdn', 'hostname').and_return(expected_fact)

      fact = Facter::Windows::NetworkingFqdn.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'returns a fact when hostname is empty' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.fqdn', value: nil)
      allow(Facter::Resolvers::Domain).to receive(:resolve).with(:domain).and_return('domain')
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return('')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.fqdn', nil).and_return(expected_fact)

      fact = Facter::Windows::NetworkingFqdn.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'returns a fact when domain is empty' do
      expected_fact = double(Facter::ResolvedFact, name: 'networking.fqdn', value: 'hostname')
      allow(Facter::Resolvers::Domain).to receive(:resolve).with(:domain).and_return('')
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return('hostname')
      allow(Facter::ResolvedFact).to receive(:new).with('networking.fqdn', 'hostname').and_return(expected_fact)

      fact = Facter::Windows::NetworkingFqdn.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
