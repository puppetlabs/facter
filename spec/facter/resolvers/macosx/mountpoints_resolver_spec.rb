# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Mountpoints do
  module Sys
    class Filesystem
      class Error < StandardError
      end
    end
  end

  let(:mount) do
    double(Sys::Filesystem::Mount,
           mount_point: '/', mount_time: nil,
           mount_type: 'ext4', options: 'rw,noatime', name:
           '/dev/nvme0n1p2', dump_frequency: 0, pass_number: 0)
  end

  let(:stat) do
    double(Sys::Filesystem::Stat,
           path: '/', base_type: nil, fragment_size: 4096, block_size: 4096, blocks: 113_879_332,
           blocks_available: 16_596_603, blocks_free: 22_398_776)
  end

  let(:fact) do
    { '/' => { available: '85.44 GiB',
               available_bytes: 91_745_386_496,
               capacity: '80.33%',
               device: '/dev/nvme0n1p2',
               filesystem: 'ext4',
               options: %w[rw noatime],
               size: '434.42 GiB',
               size_bytes: 466_449_743_872,
               used: '348.97 GiB',
               used_bytes: 374_704_357_376 } }
  end

  let(:ignored_mounts) do
    [double(Sys::Filesystem::Mount, mount_type: 'ext4', mount_point: '/proc/a', name: '/dev/ignore', options: 'rw'),
     double(Sys::Filesystem::Mount, mount_type: 'autofs', mount_point: '/mnt/auto', name: '/dev/ignore', options: 'rw')]
  end

  before do
    allow(Facter::FilesystemHelper).to receive(:read_mountpoints).and_return([mount])
    allow(Facter::FilesystemHelper).to receive(:read_mountpoint_stats).with(mount.mount_point).and_return(stat)

    # mock sys/filesystem methods
    allow(stat).to receive(:bytes_total).and_return(stat.blocks * stat.fragment_size)
    allow(stat).to receive(:bytes_available).and_return(stat.blocks_available * stat.fragment_size)
    allow(stat).to receive(:bytes_free).and_return(stat.blocks_free * stat.fragment_size)
    allow(stat).to receive(:bytes_used).and_return(stat.bytes_total - stat.bytes_free)
    described_class.invalidate_cache
  end

  it 'correctly builds the mountpoints fact' do
    result = described_class.resolve(:mountpoints)
    expect(result).to match(fact)
  end

  it 'drops automounts and non-tmpfs mounts under /proc or /sys' do
    allow(Facter::FilesystemHelper).to receive(:read_mountpoints).and_return(ignored_mounts)
    result = described_class.resolve(:mountpoints)
    expect(result).to be_empty
  end

  describe '.root_device' do
    let(:mount) do
      double(Sys::Filesystem::Mount, mount_point: '/', mount_type: 'ext4', options: 'rw,noatime', name: '/dev/root')
    end

    it 'looks up the actual device if /dev/root' do
      result = described_class.resolve(:mountpoints)
      expect(result['/'][:device]).to eq('/dev/root')
    end

    context 'when mountpoint cannot be accessed' do
      let(:expected_fact) do
        { '/' => { available: '0 bytes',
                   available_bytes: 0,
                   capacity: '100%',
                   device: '/dev/root',
                   filesystem: 'ext4',
                   options: %w[rw noatime],
                   size: '0 bytes',
                   size_bytes: 0,
                   used: '0 bytes',
                   used_bytes: 0 } }
      end

      before do
        allow(Facter::FilesystemHelper).to \
          receive(:read_mountpoint_stats).and_raise(Sys::Filesystem::Error)
      end

      it 'fallbacks to default values' do
        result = described_class.resolve(:mountpoints)
        expect(result).to eq(expected_fact)
      end
    end
  end
end
