# frozen_string_literal: true

describe Facts::Linux::Networking::Scope6 do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Scope6.new }

    let(:value) { 'link' }
    let(:interfaces) { { 'eth0' => { ip: '10.16.122.163', scope6: value } } }
    let(:primary) { 'eth0' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:interfaces).and_return(interfaces)
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:primary_interface).and_return(primary)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:interfaces)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:primary_interface)
    end

    it 'return scope6 fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.scope6', value: value)
    end
  end
end
