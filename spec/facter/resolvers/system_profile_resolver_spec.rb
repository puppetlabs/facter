# frozen_string_literal: true

describe Facter::Resolvers::SystemProfiler do
  before do
    allow(Open3).to receive(:capture2)
      .with('system_profiler SPHardwareDataType SPSoftwareDataType')
      .and_return(load_fixture('system_profiler').read)
  end

  it 'returns boot_mode' do
    result = Facter::Resolvers::SystemProfiler.resolve(:boot_mode)

    expect(result).to eq('Normal')
  end

  it 'returns boot_rom_version' do
    result = Facter::Resolvers::SystemProfiler.resolve(:boot_rom_version)

    expect(result).to eq('1037.60.58.0.0 (iBridge: 17.16.12551.0.0,0)')
  end

  it 'returns boot_volume' do
    result = Facter::Resolvers::SystemProfiler.resolve(:boot_volume)

    expect(result).to eq('Macintosh HD')
  end

  it 'returns computer_name' do
    result = Facter::Resolvers::SystemProfiler.resolve(:computer_name)

    expect(result).to eq('Test1’s MacBook Pro')
  end

  it 'returns cores' do
    result = Facter::Resolvers::SystemProfiler.resolve(:total_number_of_cores)

    expect(result).to eq('4')
  end

  it 'returns hardware_uuid' do
    result = Facter::Resolvers::SystemProfiler.resolve(:hardware_uuid)

    expect(result).to eq('12345678-1111-2222-AAAA-AABBCCDDEEFF')
  end

  it 'returns kernel_version' do
    result = Facter::Resolvers::SystemProfiler.resolve(:kernel_version)

    expect(result).to eq('Darwin 19.2.0')
  end

  it 'returns l2_cache_per_core' do
    result = Facter::Resolvers::SystemProfiler.resolve(:l2_cache_per_core)

    expect(result).to eq('256 KB')
  end

  it 'returns l3_cache' do
    result = Facter::Resolvers::SystemProfiler.resolve(:l3_cache)

    expect(result).to eq('6 MB')
  end

  it 'returns memory' do
    result = Facter::Resolvers::SystemProfiler.resolve(:memory)

    expect(result).to eq('16 GB')
  end

  it 'returns model_identifier' do
    result = Facter::Resolvers::SystemProfiler.resolve(:model_identifier)

    expect(result).to eq('MacBookPro11,4')
  end

  it 'returns model_name' do
    result = Facter::Resolvers::SystemProfiler.resolve(:model_name)

    expect(result).to eq('MacBook Pro')
  end

  it 'returns processor_name' do
    result = Facter::Resolvers::SystemProfiler.resolve(:processor_name)

    expect(result).to eq('Intel Core i7')
  end

  it 'returns processor_speed' do
    result = Facter::Resolvers::SystemProfiler.resolve(:processor_speed)

    expect(result).to eq('2.8 GHz')
  end

  it 'returns number_of_processors' do
    result = Facter::Resolvers::SystemProfiler.resolve(:number_of_processors)

    expect(result).to eq('1')
  end

  it 'returns secure_virtual_memory' do
    result = Facter::Resolvers::SystemProfiler.resolve(:secure_virtual_memory)

    expect(result).to eq('Enabled')
  end

  it 'returns serial_number' do
    result = Facter::Resolvers::SystemProfiler.resolve(:serial_number_system)

    expect(result).to eq('123456789AAA')
  end

  it 'returns smc_version' do
    result = Facter::Resolvers::SystemProfiler.resolve(:smc_version_system)

    expect(result).to eq('2.29f24')
  end

  it 'returns system_version' do
    result = Facter::Resolvers::SystemProfiler.resolve(:system_version)

    expect(result).to eq('macOS 10.15.2 (19C57)')
  end

  it 'returns time_since_boot' do
    result = Facter::Resolvers::SystemProfiler.resolve(:time_since_boot)

    expect(result).to eq('3:28')
  end

  it 'returns username' do
    result = Facter::Resolvers::SystemProfiler.resolve(:user_name)

    expect(result).to eq('Test1 Test2 (test1.test2)')
  end
end
