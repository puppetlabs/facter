# frozen_string_literal: true

describe Facter::Resolvers::Mountpoints do
  let(:mount) do
    double(Sys::Filesystem::Mount,
           mount_point: '/', mount_time: nil,
           mount_type: 'ext4', options: 'rw,noatime', name:
           '/dev/nvme0n1p2', dump_frequency: 0, pass_number: 0)
  end

  let(:stat) do
    double(Sys::Filesystem::Stat,
           path: '/', base_type: nil, fragment_size: 4096, block_size: 4096, blocks: 113_879_332,
           blocks_available: -16_596_603, blocks_free: 22_398_776)
  end

  let(:fact) do
    [{ available: '63.31 GiB',
       available_bytes: 67_979_685_888,
       capacity: '84.64%',
       device: '/dev/nvme0n1p2',
       filesystem: 'ext4',
       options: %w[rw noatime],
       path: '/',
       size: '434.42 GiB',
       size_bytes: 466_449_743_872,
       used: '348.97 GiB',
       used_bytes: 374_704_357_376 }]
  end

  let(:ignored_mounts) do
    [double(Sys::Filesystem::Mount, mount_type: 'ext4', mount_point: '/proc/a', name: '/dev/ignore', options: 'rw'),
     double(Sys::Filesystem::Mount, mount_type: 'autofs', mount_point: '/mnt/auto', name: '/dev/ignore', options: 'rw')]
  end

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/proc/cmdline')
      .and_return(load_fixture('cmdline_root_device').read)

    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoints).and_return([mount])
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoint_stats)
      .with(mount.mount_point).and_return(stat)

    # mock sys/filesystem methods
    allow(stat).to receive(:bytes_total).and_return(stat.blocks * stat.fragment_size)
    allow(stat).to receive(:bytes_available).and_return(stat.blocks_available * stat.fragment_size)
    allow(stat).to receive(:bytes_free).and_return(stat.blocks_free * stat.fragment_size)
    allow(stat).to receive(:bytes_used).and_return(stat.bytes_total - stat.bytes_free)
    Facter::Resolvers::Mountpoints.invalidate_cache
  end

  it 'correctly builds the mountpoints fact' do
    result = Facter::Resolvers::Mountpoints.resolve(:mountpoints)

    expect(result).to eq(fact)
  end

  it 'drops automounts and non-tmpfs mounts under /proc or /sys' do
    allow(Facter::Util::Resolvers::FilesystemHelper).to receive(:read_mountpoints).and_return(ignored_mounts)

    result = Facter::Resolvers::Mountpoints.resolve(:mountpoints)

    expect(result).to be_empty
  end

  describe '.root_device' do
    let(:mount) do
      double(Sys::Filesystem::Mount, mount_point: '/', mount_type: 'ext4', options: 'rw,noatime', name: '/dev/root')
    end

    it 'looks up the actual device if /dev/root' do
      result = Facter::Resolvers::Mountpoints.resolve(:mountpoints)

      expect(result.first[:device]).to eq('/dev/mmcblk0p2')
    end

    context 'when /proc/cmdline is not accessible' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/proc/cmdline')
          .and_return('')
      end

      it 'returns device as nil' do
        result = Facter::Resolvers::Mountpoints.resolve(:mountpoints)

        expect(result.first[:device]).to be(nil)
      end
    end

    context 'when root device has partuuid' do
      let(:log) { instance_spy(Facter::Log) }

      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/proc/cmdline')
          .and_return(load_fixture('cmdline_root_device_partuuid').read)
        allow(Facter::Core::Execution).to receive(:execute)
          .with('blkid', logger: log)
          .and_return(load_fixture('blkid_output_root_has_partuuid').read)
        Facter::Resolvers::Mountpoints.instance_variable_set(:@log, log)
      end

      it 'returns the path instead of the PARTUUID' do
        result = Facter::Resolvers::Mountpoints.resolve(:mountpoints)

        expect(result.first[:device]).to eq('/dev/xvda1')
      end

      context 'when blkid command is not available' do
        before do
          allow(Facter::Core::Execution).to receive(:execute)
            .with('blkid', logger: log)
            .and_return('blkid: command not found')
          Facter::Resolvers::Mountpoints.instance_variable_set(:@log, log)
        end

        it 'returns the partition path as PARTUUID' do
          result = Facter::Resolvers::Mountpoints.resolve(:mountpoints)

          expect(result.first[:device]).to eq('PARTUUID=a2f52878-01')
        end
      end
    end
  end

  describe 'resolver key not found' do
    it 'returns nil when resolver cannot find key' do
      expect(Facter::Resolvers::Mountpoints.resolve(:inexistent_key)).to be_nil
    end
  end
end
