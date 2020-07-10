# frozen_string_literal: true

describe Facts::Linux::IsVirtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::IsVirtual.new }

    let(:vm) { 'docker' }
    let(:value) { true }

    before do
      allow(Facter::Resolvers::Containers).to \
        receive(:resolve).with(:vm).and_return(vm)
    end

    it 'calls Facter::Resolvers::Containers' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Containers).to have_received(:resolve).with(:vm)
    end

    it 'returns virtual fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'is_virtual', value: value)
    end

    context 'when is gce' do
      let(:vm) { nil }
      let(:value) { true }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('Google Engine')
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is vmware' do
      let(:vm) { nil }
      let(:vmware_value) { 'vmware_fusion' }
      let(:value) { true }

      before do
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(vmware_value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is xen-hvm' do
      let(:vm) { nil }
      let(:virtwhat_value) { 'xenhvm' }
      let(:value) { true }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(virtwhat_value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is openVz' do
      let(:vm) { nil }
      let(:openvz_value) { 'openvzve' }
      let(:value) { true }

      before do
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(openvz_value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is vserver' do
      let(:vm) { nil }
      let(:virtwhat_value) { 'vserver_host' }
      let(:value) { false }

      before do
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(virtwhat_value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is xen priviledged' do
      let(:vm) { nil }
      let(:xen_value) { 'xen0' }
      let(:value) { false }

      before do
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(xen_value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is bochs discovered with dmi product_name' do
      let(:vm) { nil }
      let(:value) { true }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('Bochs Machine')
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when is hyper-v discovered with lspci' do
      let(:vm) { nil }
      let(:lspci_value) { 'hyperv' }
      let(:value) { true }

      before do
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(lspci_value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: value)
      end
    end

    context 'when resolvers return nil ' do
      let(:vm) { false }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(nil)
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(nil)
      end

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'is_virtual', value: vm)
      end
    end
  end
end
