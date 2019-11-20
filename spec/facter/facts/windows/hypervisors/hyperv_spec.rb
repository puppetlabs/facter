# frozen_string_literal: true

describe 'Windows HypervisorsHyperv' do
  describe '#call_the_resolver' do
    context 'when is not HyperV hypervisor' do
      it 'returns nil' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.hyperv', value: nil)
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
        allow(Facter::Resolvers::DMIBios).to receive(:resolve).with(:manufacturer).and_return('value')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.hyperv', nil).and_return(expected_fact)

        fact = Facter::Windows::HypervisorsHyperv.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is HyperV hypervisor and CpuidSource resolver returns the required output' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.hyperv', value: {})
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('hyperv')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.hyperv', {}).and_return(expected_fact)

        fact = Facter::Windows::HypervisorsHyperv.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is HyperV hypervisor and DmiBios resolver returns the required output' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.hyperv', value: {})
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
        allow(Facter::Resolvers::DMIBios).to receive(:resolve).with(:manufacturer).and_return('Microsoft Enterprise')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.hyperv', {}).and_return(expected_fact)

        fact = Facter::Windows::HypervisorsHyperv.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end
  end
end
