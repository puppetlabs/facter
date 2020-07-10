# frozen_string_literal: true

describe Facts::Linux::Hypervisors::Vmware do
  subject(:fact) { Facts::Linux::Hypervisors::Vmware.new }

  describe '#call_the_resolver' do
    context 'when vmware is detected' do
      context 'when VirtWhat resolver returns vmware' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('vmware')
          allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vmware_version).and_return('ESXi 6.7')
        end

        it 'returns vmware' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.vmware', value: { 'version' => 'ESXi 6.7' })
        end
      end

      context 'when DmiBios resolver with product_name returns VMware' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('VMware')
          allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vmware_version).and_return('ESXi 6.7')
        end

        it 'returns vmware' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.vmware', value: { 'version' => 'ESXi 6.7' })
        end
      end

      context 'when Lspci resolver returns vmware' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
          allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('vmware')
          allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vmware_version).and_return('ESXi 6.7')
        end

        it 'returns vmware' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.vmware', value: { 'version' => 'ESXi 6.7' })
        end
      end

      context 'when DmiBios resolver with sys_vendor returns VMware, Inc.' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
          allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('VMware, Inc.')
          allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:vmware_version).and_return('ESXi 6.7')
        end

        it 'returns vmware' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.vmware', value: { 'version' => 'ESXi 6.7' })
        end
      end
    end

    context 'when vmware is not detected' do
      before do
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:sys_vendor).and_return('unknown')
      end

      it 'returns empty list' do
        expect(fact.call_the_resolver).to eq([])
      end
    end
  end
end
