# frozen_string_literal: true

describe Facter::Resolvers::Aix::Mountpoints do
  let(:mountpoints) do
    { '/' => { available: '1.63 GiB', available_bytes: 1_747_865_600, capacity: '18.61%', device: '/dev/hd4',
               filesystem: 'jfs2', options: ['rw', 'log=/dev/hd8'], size: '2.00 GiB', size_bytes: 2_147_483_648,
               used: '381.11 MiB', used_bytes: 399_618_048 },
      '/opt' => { device: '/dev/hd10opt', filesystem: 'jfs2', options: ['rw', 'log=/dev/hd8'] },
      '/usr' => { available: '2.84 GiB', available_bytes: 3_049_021_440, capacity: '43.21%', device: '/dev/hd2',
                  filesystem: 'jfs2', options: ['rw', 'log=/dev/hd8'], size: '5.00 GiB', size_bytes: 5_368_709_120,
                  used: '2.16 GiB', used_bytes: 2_319_687_680 } }
  end

  before do
    allow(Open3).to receive(:capture2).with('mount 2>/dev/null').and_return(load_fixture('mount').read)
    allow(Open3).to receive(:capture2).with('df -P 2>/dev/null').and_return(load_fixture('df').read)
  end

  it 'returns mountpoints' do
    result = Facter::Resolvers::Aix::Mountpoints.resolve(:mountpoints)

    expect(result).to eq(mountpoints)
  end
end
