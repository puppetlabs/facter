# frozen_string_literal: true

describe 'Windows HypervisorsXen' do
  describe '#call_the_resolver' do
    context 'when is not xen hypervisor' do
      it 'returns nil' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.xen', value: nil)
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.xen', nil).and_return(expected_fact)

        fact = Facter::Windows::HypervisorsXen.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is xen hypervisor and context not hvm' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.xen', value: { context: 'pv' })
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('xen')
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('PV domU')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.xen', context: 'pv').and_return(expected_fact)

        fact = Facter::Windows::HypervisorsXen.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is xen hypervisor and context hvm' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.xen', value: { context: 'hvm' })
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('xen')
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('HVM domU')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.xen', context: 'hvm').and_return(expected_fact)

        fact = Facter::Windows::HypervisorsXen.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end
  end
end
