# frozen_string_literal: true

describe Facter::Windows::NetworkingFqdn do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Windows::NetworkingFqdn.new }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:domain).and_return(domain_name)
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return(hostname)
    end

    context 'when domain and hostname could be resolved' do
      let(:domain_name) { 'domain' }
      let(:hostname) { 'hostname' }
      let(:value) { "#{hostname}.#{domain_name}" }

      it 'calls Facter::Resolvers::Networking and Facter::Resolvers::Hostname' do
        expect(Facter::Resolvers::Networking).to receive(:resolve).with(:domain)
        expect(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname)
        fact.call_the_resolver
      end

      it 'returns fqdn fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.fqdn', value: value),
                          an_object_having_attributes(name: 'fqdn', value: value, type: :legacy))
      end
    end

    context 'when it fails to retrieve hostname' do
      let(:domain_name) { 'domain' }
      let(:hostname) { nil }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'networking.fqdn', value: nil)
      end
    end

    context 'when it fails to retrieve domain' do
      let(:domain_name) { nil }
      let(:hostname) { 'hostname' }
      let(:value) { hostname }

      it 'returns hostname as fqdn' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'networking.fqdn', value: value),
                          an_object_having_attributes(name: 'fqdn', value: value, type: :legacy))
      end
    end

    context 'when hostname is empty' do
      let(:domain_name) { 'domain' }
      let(:hostname) { '' }
      let(:value) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'networking.fqdn', value: nil)
      end
    end
  end
end
