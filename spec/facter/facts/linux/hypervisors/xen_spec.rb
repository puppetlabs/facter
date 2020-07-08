# frozen_string_literal: true

describe Facts::Linux::Hypervisors::Xen do
  subject(:fact) { Facts::Linux::Hypervisors::Xen.new }

  describe '#call_the_resolver' do
    context 'when xen hypervisor' do
      context 'when VirtWhat resolver returns xen' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('xen')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('xenhvm')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(false)
        end

        it 'calls Facter::Resolvers::VirtWhat' do
          fact.call_the_resolver

          expect(Facter::Resolvers::VirtWhat).to have_received(:resolve).with(:vm)
        end

        it 'returns xen' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => false })
        end
      end

      context 'when Xen resolver returns xen0' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return('xen0')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('HVM domU')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(true)
        end

        it 'calls Facter::Resolvers::Xen' do
          fact.call_the_resolver

          expect(Facter::Resolvers::Xen).to have_received(:resolve).with(:vm)
        end

        it 'returns xen' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => true })
        end
      end

      context 'when DmiBios resolver return HVM domU' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('HVM domU')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(true)
        end

        it 'calls Facter::Resolvers::Linux::DmiBios' do
          fact.call_the_resolver

          expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:product_name).twice
        end

        it 'returns xen' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => true })
        end
      end

      context 'when Lspci resolver returns xenhvm' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(true)
          allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('xenhvm')
        end

        it 'calls Facter::Resolvers::Linux::DmiBios' do
          fact.call_the_resolver

          expect(Facter::Resolvers::Lspci).to have_received(:resolve).with(:vm).twice
        end

        it 'returns xen' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => true })
        end
      end

      context 'when hvm context' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('xen')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('xenhvm')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(false)
        end

        it 'returns xen with hvm context' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => false })
        end
      end

      context 'when pv context' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('xen')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
          allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('unknown')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(false)
        end

        it 'returns xen with pv context' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'pv', 'privileged' => false })
        end
      end

      context 'when privileged' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('xen')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('xenhvm')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(true)
        end

        it 'returns privileged xen' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => true })
        end
      end

      context 'when unprivileged' do
        before do
          allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('xen')
          allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('xenhvm')
          allow(Facter::Resolvers::Xen).to receive(:resolve).with(:privileged).and_return(false)
        end

        it 'returns privileged xen' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
            .and have_attributes(name: 'hypervisors.xen', value: { 'context' => 'hvm', 'privileged' => false })
        end
      end
    end

    context 'when not xen hypervisor' do
      before do
        allow(Facter::Resolvers::VirtWhat).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Xen).to receive(:resolve).with(:vm).and_return('unknown')
        allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:product_name).and_return('unknown')
        allow(Facter::Resolvers::Lspci).to receive(:resolve).with(:vm).and_return('unknown')
      end

      it 'returns empty array' do
        expect(fact.call_the_resolver).to eq([])
      end
    end
  end
end
