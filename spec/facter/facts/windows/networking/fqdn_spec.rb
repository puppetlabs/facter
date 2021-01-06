# frozen_string_literal: true

describe Facts::Windows::Networking::Fqdn do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Fqdn.new }

    before do
      allow(Facter::Resolvers::Windows::Networking).to receive(:resolve).with(:domain).and_return(domain_name)
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return(hostname)
    end

    context 'when domain and hostname could be resolved' do
      let(:domain_name) { 'domain' }
      let(:hostname) { 'hostname' }
      let(:value) { "#{hostname}.#{domain_name}" }

      it 'calls Facter::Resolvers::Windows::Networking' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Networking).to have_received(:resolve).with(:domain)
      end

      it 'calls Facter::Resolvers::Hostname' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Hostname).to have_received(:resolve).with(:hostname)
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

    context 'when domain is empty string' do
      let(:domain_name) { '' }
      let(:hostname) { 'hostname' }
      let(:value) { hostname }

      it 'returns hostname as fqdn without a trailing dot' do
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
