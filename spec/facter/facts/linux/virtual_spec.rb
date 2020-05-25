# frozen_string_literal: true

describe Facts::Linux::Virtual do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Virtual.new }

    let(:vm) { 'docker' }

    before do
      allow(Facter::Resolvers::DockerLxc).to \
        receive(:resolve).with(:vm).and_return(vm)
    end

    it 'calls Facter::Resolvers::DockerLxc' do
      fact.call_the_resolver
      expect(Facter::Resolvers::DockerLxc).to have_received(:resolve).with(:vm)
    end

    it 'returns virtual fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'virtual', value: vm)
    end

    context 'when is gce' do
      let(:vm) { nil }
      let(:value) { 'gce' }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return('Google Engine')
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is vmware' do
      let(:vm) { nil }
      let(:value) { 'vmware_fusion' }

      before do
        allow(Facter::Resolvers::Vmware).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when is xen-hvm' do
      let(:vm) { nil }
      let(:value) { 'xenhvm' }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return(value)
      end

      it 'returns virtual fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: value)
      end
    end

    context 'when resolver returns nil' do
      let(:vm) { nil }

      before do
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:bios_vendor).and_return(nil)
      end

      it 'returns virtual fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'virtual', value: vm)
      end
    end
  end
end
