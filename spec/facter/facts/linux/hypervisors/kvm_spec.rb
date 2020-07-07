# frozen_string_literal: true

describe Facts::Linux::Hypervisors::Kvm do
  subject(:fact) { Facts::Linux::Hypervisors::Kvm.new }

  describe '#call_the_resolver' do
    context 'when hypervisor is virtualbox' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('VirtualBox')
      end

      it 'calls  Facter::Resolvers::Linux::DmiBios' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name)
      end

      it 'has nil value' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: nil)
      end
    end

    context 'when hypervisor is parallels' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('Parallels')
      end

      it 'calls  Facter::Resolvers::Linux::DmiBios' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name)
      end

      it 'has nil value' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: nil)
      end
    end

    context 'when VirtWhat retuns kvm' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('KVM')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('unknown')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('unknown')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('kvm')
      end

      it 'calls  Facter::Resolvers::VirtWhat' do
        fact.call_the_resolver

        expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vm)
      end

      it 'returns empty hash' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: {})
      end
    end

    context 'when Lspci returns kvm' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('KVM')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('unknown')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('unknown')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('kvm')
      end

      it 'calls Facter::Resolvers::Lspci' do
        fact.call_the_resolver

        expect(Facter::Resolvers::Lspci).to have_received(:resolve).with(:vm)
      end

      it 'returns empty hash' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: {})
      end
    end

    context 'when VM is provided by AWS with KVM hypervisor' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('KVM')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('Amazon EC2')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('Amazon')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('unknown')
      end

      it 'returns aws' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: { 'amazon' => true })
      end
    end

    context 'when VM is provided by GCE with KVM hypervisor' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('KVM')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('Google')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('Google')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('unknown')
      end

      it 'returns google cloud' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: { 'google' => true })
      end
    end

    context 'when VM is provided by OpenStack with KVM hypervisor' do
      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('KVM')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('OpenStack')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('OpenStack')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('kvm')
      end

      it 'returns open stack' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'hypervisors.kvm', value: { 'openstack' => true })
      end
    end
  end
end
