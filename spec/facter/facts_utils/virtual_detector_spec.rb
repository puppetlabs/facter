# frozen_string_literal: true

describe Facter::VirtualDetector do
  subject(:detector) { Facter::VirtualDetector.new }

  describe '#platform' do
    let(:logger_mock) { instance_spy(Facter::Log) }

    before do
      allow(Facter::Log).to receive(:new).and_return(logger_mock)
    end

    context 'when in docker' do
      let(:vm) { 'docker' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(vm)
      end

      it 'calls Facter::Resolvers::Containers' do
        detector.platform
        expect(Facter::Resolvers::Containers).to have_received(:resolve).with(:vm)
      end

      it 'returns container type' do
        expect(detector.platform).to eq(vm)
      end
    end

    context 'when detecting with dmidecore' do
      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
      end

      context 'when on Amazon' do
        let(:platform) { 'Amazon' }

        before do
          allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(platform)
        end

        it 'calls Facter::Resolvers::DmiDecode' do
          detector.platform

          expect(Facter::Resolvers::DmiDecode).to have_received(:resolve).with(:vendor)
        end

        it 'returns vendor' do
          expect(detector.platform).to eq('aws')
        end
      end

      context 'when on XEN' do
        let(:platform) { 'Xen' }

        before do
          allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(platform)
        end

        it 'calls Facter::Resolvers::DmiDecode' do
          detector.platform

          expect(Facter::Resolvers::DmiDecode).to have_received(:resolve).with(:vendor)
        end

        it 'returns vendor' do
          expect(detector.platform).to eq('xen')
        end
      end
    end

    context 'when is gce' do
      let(:value) { 'gce' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('Google Engine')
      end

      it 'calls Facter::Resolvers::Linux::DmiBios' do
        detector.platform

        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:bios_vendor)
      end

      it 'returns gce' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is xen-hvm' do
      let(:value) { 'xenhvm' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'calls Facter::Resolvers::VirtWhat' do
        detector.platform

        expect(Facter::Resolvers::VirtWhat). to have_received(:resolve).with(:vm)
      end

      it 'returns xen' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is vmware' do
      let(:value) { 'vmware_fusion' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'calls Facter::Resolvers::Vmware' do
        detector.platform

        expect(Facter::Resolvers::Vmware).to have_received(:resolve).with(:vm)
      end

      it 'returns vmware' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is openVz' do
      let(:value) { 'openvzve' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'calls Facter::Resolvers::OpenVz' do
        detector.platform

        expect(Facter::Resolvers::OpenVz).to have_received(:resolve).with(:vm)
      end

      it 'returns openvz' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is vserver' do
      let(:value) { 'vserver_host' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(value)
      end

      it 'calls Facter::Resolvers::VirtWhat' do
        detector.platform

        expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vserver)
      end

      it 'returns vserver' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is xen priviledged' do
      let(:value) { 'xen0' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'calls Facter::Resolvers::Xen' do
        detector.platform

        expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:vm)
      end

      it 'returns xen' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is bochs discovered with dmi product_name' do
      let(:value) { 'bochs' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('Bochs Machine')
      end

      it 'calls Facter::Resolvers::Linux::DmiBios with bios_vendor' do
        detector.platform

        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:bios_vendor).twice
      end

      it 'calls Facter::Resolvers::Linux::DmiBios with product_name' do
        detector.platform

        expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name)
      end

      it 'returns bosch' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when is hyper-v discovered with lspci' do
      let(:value) { 'hyperv' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(nil)
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'calls Facter::Resolvers::Lspci' do
        detector.platform

        expect(Facter::Resolvers::Lspci).to have_received(:resolve).with(:vm)
      end

      it 'returns hyper-v' do
        expect(detector.platform).to eq(value)
      end
    end

    context 'when all resolvers return nil ' do
      let(:vm) { 'physical' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::OpenVz).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vserver).and_return(nil)
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(nil)
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(nil)
      end

      it 'returns physiscal' do
        expect(detector.platform).to eq(vm)
      end
    end

    context 'when product name is not found in the HYPERVISORS_HASH' do
      let(:vm) { 'physical' }

      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve).with(:vm).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vendor).and_return(nil)
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
        expect(detector.platform).to eq(vm)
      end
    end
  end
end
