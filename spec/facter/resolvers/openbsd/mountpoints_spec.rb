# frozen_string_literal: true

describe Facter::Resolvers::Openbsd::Mountpoints do
  let(:mountpoints) do
    { '/' => { available: '738.97 MiB', available_bytes: 774_868_992, capacity: '20.04%', device: '/dev/sd0a',
               filesystem: 'ffs', options: ['local'], size: '985.76 MiB', size_bytes: 1_033_648_128,
               used: '197.50 MiB', used_bytes: 207_097_856 },
      '/usr' => { available: '157.56 MiB', available_bytes: 165_216_256, capacity: '79.02%', device: '/dev/sd0d',
                  filesystem: 'ffs', options: %w[local nodev], size: '985.76 MiB', size_bytes: 1_033_648_128,
                  used: '778.91 MiB', used_bytes: 816_750_592 },
      '/usr/local' => { available: '1.10 GiB', available_bytes: 1_178_118_144, capacity: '57.17%',
                        device: '/dev/sd0e', filesystem: 'ffs', options: %w[local nodev wxallowed],
                        size: '2.90 GiB', size_bytes: 3_114_448_896, used: '1.66 GiB',
                        used_bytes: 1_780_609_024 } }
  end

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('mount', logger: an_instance_of(Facter::Log))
      .and_return(load_fixture('openbsd_filesystems').read)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('df -P', logger: an_instance_of(Facter::Log))
      .and_return(load_fixture('openbsd_df').read)
  end

  it 'returns mountpoints' do
    result = Facter::Resolvers::Openbsd::Mountpoints.resolve(:mountpoints)

    expect(result).to eq(mountpoints)
  end
end
