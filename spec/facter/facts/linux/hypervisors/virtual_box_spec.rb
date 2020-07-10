# frozen_string_literal: true

describe Facts::Linux::Hypervisors::VirtualBox do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Hypervisors::VirtualBox.new }

    let(:version) { '6.4.1' }
    let(:revision) { '136177' }
    let(:value) { { 'version' => version, 'revision' => revision } }

    before do
      allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:virtualbox_version).and_return(version)
      allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:virtualbox_revision).and_return(revision)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('VirtualBox')
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name)
    end

    it 'calls Facter::Resolvers::DmiDecode with version' do
      fact.call_the_resolver
      expect(Facter::Resolvers::DmiDecode).to have_received(:resolve).with(:virtualbox_version)
    end

    it 'calls Facter::Resolvers::DmiDecode with revision' do
      fact.call_the_resolver
      expect(Facter::Resolvers::DmiDecode).to have_received(:resolve).with(:virtualbox_revision)
    end

    it 'returns virtualbox fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'hypervisors.virtualbox', value: value)
    end

    context 'when virtualbox is not detected' do
      let(:value) { nil }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('other')
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('other')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('other')
      end

      it 'returns nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.virtualbox', value: value)
      end
    end

    context 'when virtualbox details are not present' do
      let(:value) { {} }

      before do
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:virtualbox_version).and_return(nil)
        allow(Facter::Resolvers::DmiDecode).to receive(:resolve).with(:virtualbox_revision).and_return(nil)
      end

      it 'returns virtualbox fact as empty hash' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'hypervisors.virtualbox', value: value)
      end
    end
  end
end
