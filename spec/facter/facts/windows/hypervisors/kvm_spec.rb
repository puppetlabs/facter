# frozen_string_literal: true

describe Facts::Windows::Hypervisors::Kvm do
  describe '#call_the_resolver' do
    context 'when is not kvm hypervisor' do
      it 'returns nil' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.kvm', value: nil)
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
        allow(Facter::Resolvers::NetKVM).to receive(:resolve).with(:kvm).and_return(false)
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('value')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.kvm', nil).and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Kvm.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is kvm hypervisor but product name is parallels' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.kvm', value: nil)
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('kvm')
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('Parallels')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.kvm', nil).and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Kvm.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is kvm hypervisor and openstack' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.kvm', value: { openstack: true })
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('kvm')
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('OpenStack')
        allow(Facter::Resolvers::DMIBios).to receive(:resolve).with(:manufacturer).and_return('value')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.kvm', openstack: true).and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Kvm.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is kvm hypervisor and gce' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.kvm', value: { google: true })
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('gce')
        allow(Facter::Resolvers::NetKVM).to receive(:resolve).with(:kvm).and_return(true)
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('value')
        allow(Facter::Resolvers::DMIBios).to receive(:resolve).with(:manufacturer).and_return('Google')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.kvm', google: true).and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Kvm.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end
  end
end
