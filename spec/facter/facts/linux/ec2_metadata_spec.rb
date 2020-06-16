# frozen_string_literal: true

describe Facts::Linux::Ec2Metadata do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Ec2Metadata.new }

    before do
      allow(Facter::Resolvers::Ec2).to receive(:resolve).with(:metadata).and_return(value)
      allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(hypervisor)
      allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return(nil)
      allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return(nil)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return(nil)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
    end

    context 'when hypervisor is not kvm or xen' do
      let(:hypervisor) { nil }
      let(:value) { nil }

      it 'returns ec2 metadata fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ec2_metadata', value: nil)
      end

      it "doesn't call Ec2 resolver" do
        fact.call_the_resolver
        expect(Facter::Resolvers::Ec2).not_to have_received(:resolve).with(:metadata)
      end
    end

    context 'when hypervisor is xen' do
      let(:hypervisor) { 'xenhvm' }

      context 'when resolver returns a value' do
        let(:value) { { 'info' => 'value' } }

        it 'calls Facter::Resolvers::Ec2' do
          fact.call_the_resolver
          expect(Facter::Resolvers::Ec2).to have_received(:resolve).with(:metadata)
        end

        it 'returns ec2 userdata fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'ec2_metadata', value: value)
        end
      end

      context 'when resolver returns empty hash' do
        let(:value) { {} }

        it 'returns ec2 userdata fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'ec2_metadata', value: nil)
        end
      end
    end
  end
end
