# frozen_string_literal: true

describe Facter::Util::Macosx::SystemProfileExecutor do
  subject(:system_profiler_executor) { Facter::Util::Macosx::SystemProfileExecutor }

  describe '#execute' do
    before do
      allow(Facter::Core::Execution).to receive(:execute)
    end

    it 'calls Facter::Core::Execution.execute' do
      system_profiler_executor.execute('SPEthernetDataType')

      expect(Facter::Core::Execution).to have_received(:execute)
    end

    context 'when executing system_profiler with SPEthernetDataType argument' do
      let(:eth_data_hash) do
        {
          type: 'Ethernet Controller',
          bus: 'PCI',
          vendor_id: '0x8086',
          device_id: '0x100f',
          subsystem_vendor_id: '0x1ab8',
          subsystem_id: '0x0400',
          revision_id: '0x0000',
          bsd_name: 'en0',
          kext_name: 'AppleIntel8254XEthernet.kext',
          location: '/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/AppleIntel8254XEthernet.kext',
          version: '3.1.5'
        }
      end

      before do
        allow(Facter::Core::Execution)
          .to receive(:execute)
          .with('system_profiler SPEthernetDataType', any_args)
          .and_return(load_fixture('system_profile_sp_ethernet_data_type').read)
      end

      it 'returns a hash with the information' do
        ethernet_data_type_hash = system_profiler_executor.execute('SPEthernetDataType')

        expect(ethernet_data_type_hash).to eq(eth_data_hash)
      end
    end
  end
end
