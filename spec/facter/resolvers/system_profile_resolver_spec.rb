# frozen_string_literal: true

describe Facter::Resolvers::Macosx::SystemProfiler do
  subject(:system_profiler) { Facter::Resolvers::SystemProfiler }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    system_profiler.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('system_profiler SPHardwareDataType SPSoftwareDataType', logger: log_spy)
      .and_return(load_fixture('system_profiler').read)
  end

  it 'returns boot_mode' do
    expect(system_profiler.resolve(:boot_mode)).to eq('Normal')
  end

  it 'returns boot_rom_version' do
    expect(system_profiler.resolve(:boot_rom_version)).to eq('1037.60.58.0.0 (iBridge: 17.16.12551.0.0,0)')
  end

  it 'returns boot_volume' do
    expect(system_profiler.resolve(:boot_volume)).to eq('Macintosh HD')
  end

  it 'returns computer_name' do
    expect(system_profiler.resolve(:computer_name)).to eq('Test1’s MacBook Pro')
  end

  it 'returns cores' do
    expect(system_profiler.resolve(:total_number_of_cores)).to eq('4')
  end

  it 'returns hardware_uuid' do
    expect(system_profiler.resolve(:hardware_uuid)).to eq('12345678-1111-2222-AAAA-AABBCCDDEEFF')
  end

  it 'returns kernel_version' do
    expect(system_profiler.resolve(:kernel_version)).to eq('Darwin 19.2.0')
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

  it 'returns secure_virtual_memory' do
    expect(system_profiler.resolve(:secure_virtual_memory)).to eq('Enabled')
  end

  it 'returns serial_number' do
    expect(system_profiler.resolve(:serial_number_system)).to eq('123456789AAA')
  end

  it 'returns smc_version' do
    expect(system_profiler.resolve(:smc_version_system)).to eq('2.29f24')
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
