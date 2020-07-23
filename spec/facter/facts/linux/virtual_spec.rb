# frozen_string_literal: true

describe Facts::Linux::Virtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Virtual.new }

    context 'when is docker' do
      let(:vm) { 'docker' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(vm)
      end

      it 'calls Facter::Resolvers::Containers' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Containers).to have_received(:resolve).with(:vm)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end

    context 'when is gce' do
      let(:value) { 'gce' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('Google Engine')
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is xen-hvm' do
      let(:value) { 'xenhvm' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is vmware' do
      let(:value) { 'vmware_fusion' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is openVz' do
      let(:value) { 'openvzve' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is vserver' do
      let(:value) { 'vserver_host' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is xen priviledged' do
      let(:value) { 'xen0' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is bochs discovered with dmi product_name' do
      let(:value) { 'bochs' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('Bochs Machine')
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is hyper-v discovered with lspci' do
      let(:value) { 'hyperv' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(nil)
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when resolvers return nil ' do
      let(:vm) { 'physical' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(nil)
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(nil)
      end

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end

    context 'when product name is not found in the HYPERVISORS_HASH' do
      let(:vm) { 'physical' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('unknown')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
      end

      it 'returns virtual fact as physical' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end
  end
end
