# frozen_string_literal: true

describe Facts::Windows::Hypervisors::Virtualbox do
  describe '#call_the_resolver' do
    context 'when is not Virtualbox hypervisor' do
      it 'returns nil' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.virtualbox', value: nil)
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('value')
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.virtualbox', nil).and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Virtualbox.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is VirtualBox hypervisor and CpuidSource resolver returns the required output' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.virtualbox', value:
            { revision: ' 13.4', version: ' 13.4' })
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('virtualbox')
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:oem_strings)
                                                                     .and_return(['vboxVer_ 13.4', 'vboxRev_ 13.4'])
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.virtualbox', revision: ' 13.4', version: ' 13.4')
                                                    .and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Virtualbox.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end

    context 'when is VirtualBox hypervisor and DMIComputerSystem resolver returns the required output' do
      it 'returns a fact' do
        expected_fact = double(Facter::ResolvedFact, name: 'hypervisors.virtualbox', value:
            { revision: '', version: '' })
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
        allow(Facter::Resolvers::DMIComputerSystem).to receive(:resolve).with(:name).and_return('VirtualBox')
        allow(Facter::Resolvers::Virtualization).to receive(:resolve).with(:oem_strings).and_return(['', ''])
        allow(Facter::ResolvedFact).to receive(:new).with('hypervisors.virtualbox', revision: '', version: '')
                                                    .and_return(expected_fact)

        fact = Facts::Windows::Hypervisors::Virtualbox.new
        expect(fact.call_the_resolver).to eq(expected_fact)
      end
    end
  end
end
