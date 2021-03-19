# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Mountpoints do
  let(:resolver) { Facter::Resolvers::Solaris::Mountpoints }
  let(:mounts) do
    [
      object_double(Sys::Filesystem::Mount,
                    mount_point: '/', mount_time: nil,
                    mount_type: 'zfs', options: 'dev=4490002', name:
                    'rpool/ROOT/solaris', dump_frequency: nil, pass_number: nil),
      object_double(Sys::Filesystem::Mount,
                    mount_point: '/devices', mount_time: nil,
                    mount_type: 'devfs', options: 'dev=8580000', name:
                    '/devices', dump_frequency: nil, pass_number: nil),
      object_double(Sys::Filesystem::Mount,
                    mount_point: '/proc', mount_time: nil,
                    mount_type: 'proc', options: 'dev=8600000', name:
                    'proc', dump_frequency: nil, pass_number: nil),
      object_double(Sys::Filesystem::Mount,
                    mount_point: '/net', mount_time: nil,
                    mount_type: 'autofs', options: 'nosuid,indirect,ignore,nobrowse,dev=8900007', name:
                    '-hosts', dump_frequency: nil, pass_number: nil),
      object_double(Sys::Filesystem::Mount,
                    mount_point: '/home', mount_time: nil,
                    mount_type: 'autofs', options: 'indirect,ignore,nobrowse,dev=8900008', name:
                    'auto_home', dump_frequency: nil, pass_number: nil),
      object_double(Sys::Filesystem::Mount,
                    mount_point: '/home/user', mount_time: nil,
                    mount_type: 'zfs', options: 'dev=8900009', name:
                    'rpool/user', dump_frequency: nil, pass_number: nil)
    ]
  end

  let(:mount) { mounts.first }

  let(:stat) do
    object_double('Sys::Filesystem::Stat',
                  path: '/', base_type: 'zfs', fragment_size: 512, block_size: 131_072, blocks: 20_143_706,
                  blocks_available: 11_731_043, blocks_free: 11_731_043)
  end

  let(:fact) do
    [{ available: '5.59 GiB',
       available_bytes: 6_006_294_016,
       capacity: '41.76%',
       device: 'rpool/ROOT/solaris',
       filesystem: 'zfs',
       options: ['dev=4490002'],
       path: '/',
       size: '9.61 GiB',
       size_bytes: 10_313_577_472,
       used: '4.01 GiB',
       used_bytes: 4_307_283_456 }]
  end

  before do
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoint_stats).and_return(stat)

    # mock sys/filesystem methods
    allow(stat).to receive(:bytes_total).and_return(stat.blocks * stat.fragment_size)
    allow(stat).to receive(:bytes_available).and_return(stat.blocks_available * stat.fragment_size)
    allow(stat).to receive(:bytes_free).and_return(stat.blocks_free * stat.fragment_size)
    allow(stat).to receive(:bytes_used).and_return(stat.bytes_total - stat.bytes_free)

    resolver.invalidate_cache
  end

  it 'correctly builds the mountpoints fact' do
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoints).and_return([mount])
    result = resolver.resolve(:mountpoints)

    expect(result).to eq(fact)
  end

  it 'resolves all applicable mountpoints' do
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoints).and_return(mounts)

    result = resolver.resolve(:mountpoints)
    expect(result.map { |m| m[:path] }).to eql(%w[/ /devices /proc])
  end

  it 'does not resolve mounts of type autofs' do
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoints).and_return(mounts)

    result = resolver.resolve(:mountpoints)
    expect(result).not_to include(hash_including(filesystem: 'autofs'))
  end

  it 'does not resolve mounts under auto_home' do
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoints).and_return(mounts)

    result = resolver.resolve(:mountpoints)
    expect(result).not_to include(hash_including(path: '/home/user'))
  end

  describe 'resolver key not found' do
    it 'returns nil when resolver cannot find key' do
      expect(resolver.resolve(:inexistent_key)).to be_nil
    end
  end
end
