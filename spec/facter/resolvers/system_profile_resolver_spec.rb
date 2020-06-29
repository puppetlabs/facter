# frozen_string_literal: true

describe Facter::Resolvers::Macosx::SystemProfiler do
  subject(:system_profiler) { Facter::Resolvers::Macosx::SystemProfiler }

  let(:log_spy) { instance_spy(Facter::Log) }

  let(:sp_hardware_data_type_hash) do
    {
      model_name: 'MacBook Pro',
      model_identifier: 'MacBookPro11,4',
      processor_name: 'Intel Core i7',
      processor_speed: '2.8 GHz',
      number_of_processors: '1',
      total_number_of_cores: '4',
      l2_cache_per_core: '256 KB',
      l3_cache: '6 MB',
      'hyper-threading_technology': 'Enabled',
      memory: '16 GB',
      boot_rom_version: '1037.60.58.0.0 (iBridge: 17.16.12551.0.0,0)',
      smc_version_system: '2.29f24',
      serial_number_system: '123456789AAA',
      hardware_uuid: '12345678-1111-2222-AAAA-AABBCCDDEEFF',
      activation_lock_status: 'Disabled'
    }
  end

  let(:sp_software_data_type) do
    {
      system_version: 'macOS 10.15.2 (19C57)',
      kernel_version: 'Darwin 19.2.0',
      boot_volume: 'Macintosh HD',
      boot_mode: 'Normal',
      computer_name: 'Test1’s MacBook Pro',
      user_name: 'Test1 Test2 (test1.test2)',
      secure_virtual_memory: 'Enabled',
      system_integrity_protection: 'Enabled',
      time_since_boot: '3:28'
    }
  end

  let(:sp_ethernet_data_type) do
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
    system_profiler.instance_variable_set(:@log, log_spy)
  end

  context 'when information is obtain from SPHardwareDataType' do
    before do
      allow(Facter::Resolvers::Macosx::SystemProfileExecutor)
        .to receive(:execute)
        .with('SPHardwareDataType')
        .and_return(sp_hardware_data_type_hash)
    end

    it 'returns boot_rom_version' do
      expect(system_profiler.resolve(:boot_rom_version)).to eq('1037.60.58.0.0 (iBridge: 17.16.12551.0.0,0)')
    end

    it 'returns cores' do
      expect(system_profiler.resolve(:total_number_of_cores)).to eq('4')
    end

    it 'returns hardware_uuid' do
      expect(system_profiler.resolve(:hardware_uuid)).to eq('12345678-1111-2222-AAAA-AABBCCDDEEFF')
    end

    it 'returns l2_cache_per_core' do
      expect(system_profiler.resolve(:l2_cache_per_core)).to eq('256 KB')
    end

    it 'returns l3_cache' do
      expect(system_profiler.resolve(:l3_cache)).to eq('6 MB')
    end

    it 'returns memory' do
      expect(system_profiler.resolve(:memory)).to eq('16 GB')
    end

    it 'returns model_identifier' do
      expect(system_profiler.resolve(:model_identifier)).to eq('MacBookPro11,4')
    end

    it 'returns model_name' do
      expect(system_profiler.resolve(:model_name)).to eq('MacBook Pro')
    end

    it 'returns processor_name' do
      expect(system_profiler.resolve(:processor_name)).to eq('Intel Core i7')
    end

    it 'returns processor_speed' do
      expect(system_profiler.resolve(:processor_speed)).to eq('2.8 GHz')
    end

    it 'returns number_of_processors' do
      expect(system_profiler.resolve(:number_of_processors)).to eq('1')
    end

    it 'returns serial_number' do
      expect(system_profiler.resolve(:serial_number_system)).to eq('123456789AAA')
    end

    it 'returns smc_version' do
      expect(system_profiler.resolve(:smc_version_system)).to eq('2.29f24')
    end
  end

  context 'when information is obtained from SPSoftwareDataType' do
    before do
      allow(Facter::Resolvers::Macosx::SystemProfileExecutor)
        .to receive(:execute)
        .with('SPSoftwareDataType')
        .and_return(sp_software_data_type)
    end

    it 'returns boot_mode' do
      expect(system_profiler.resolve(:boot_mode)).to eq('Normal')
    end

    it 'returns boot_volume' do
      expect(system_profiler.resolve(:boot_volume)).to eq('Macintosh HD')
    end

    it 'returns computer_name' do
      expect(system_profiler.resolve(:computer_name)).to eq('Test1’s MacBook Pro')
    end

    it 'returns kernel_version' do
      expect(system_profiler.resolve(:kernel_version)).to eq('Darwin 19.2.0')
    end

    it 'returns secure_virtual_memory' do
      expect(system_profiler.resolve(:secure_virtual_memory)).to eq('Enabled')
    end

    it 'returns system_version' do
      expect(system_profiler.resolve(:system_version)).to eq('macOS 10.15.2 (19C57)')
    end

    it 'returns time_since_boot' do
      expect(system_profiler.resolve(:time_since_boot)).to eq('3:28')
    end

    it 'returns username' do
      expect(system_profiler.resolve(:user_name)).to eq('Test1 Test2 (test1.test2)')
    end
  end

  context 'when information is obtained from SPEthernetDataType' do
    before do
      allow(Facter::Resolvers::Macosx::SystemProfileExecutor)
        .to receive(:execute)
        .with('SPEthernetDataType')
        .and_return(sp_ethernet_data_type)
    end

    it 'returns type' do
      expect(system_profiler.resolve(:type)).to eq('Ethernet Controller')
    end

    it 'returns bus' do
      expect(system_profiler.resolve(:bus)).to eq('PCI')
    end

    it 'returns vendor_id' do
      expect(system_profiler.resolve(:vendor_id)).to eq('0x8086')
    end

    it 'returns device_id' do
      expect(system_profiler.resolve(:device_id)).to eq('0x100f')
    end

    it 'returns subsystem_vendor_id' do
      expect(system_profiler.resolve(:subsystem_vendor_id)).to eq('0x1ab8')
    end

    it 'returns subsystem_id' do
      expect(system_profiler.resolve(:subsystem_id)).to eq('0x0400')
    end

    it 'returns revision_id' do
      expect(system_profiler.resolve(:revision_id)).to eq('0x0000')
    end

    it 'returns bsd_name' do
      expect(system_profiler.resolve(:bsd_name)).to eq('en0')
    end

    it 'returns kext_name' do
      expect(system_profiler.resolve(:kext_name)).to eq('AppleIntel8254XEthernet.kext')
    end

    it 'returns location' do
      expect(system_profiler.resolve(:location))
        .to eq('/System/Library/Extensions/IONetworkingFamily.kext/Contents/PlugIns/AppleIntel8254XEthernet.kext')
    end

    it 'returns version' do
      expect(system_profiler.resolve(:version)).to eq('3.1.5')
    end
  end
end
