# frozen_string_literal: true

describe Facter::Resolvers::Partitions do
  subject(:resolver) { Facter::Resolvers::Partitions }

  let(:sys_block_path) { '/sys/block' }
  let(:sys_block_subdirs) { ['.', '..', 'sda'] }

  after do
    Facter::Resolvers::Partitions.invalidate_cache
  end

  context 'when /sys/block is not readable' do
    before do
      allow(File).to receive(:readable?).with(sys_block_path).and_return(false)
    end

    it 'returns empty hash' do
      expect(resolver.resolve(:partitions)).to eq({})
    end
  end

  context 'when /sys/block is readable' do
    before do
      allow(File).to receive(:readable?).with(sys_block_path).and_return(true)
      allow(Dir).to receive(:entries).with(sys_block_path).and_return(sys_block_subdirs)
    end

    context 'when block has a device subdir' do
      let(:sda_subdirs) do
        ['/sys/block/sda/queue',
         '/sys/block/sda/sda2',
         '/sys/block/sda/sda2/stat',
         '/sys/block/sda/sda2/dev',
         '/sys/block/sda/sda2/uevent',
         '/sys/block/sda/sda1']
      end

      let(:partitions) do
        { '/dev/sda1' => { filesystem: 'ext3', label: '/boot', size: '117.00 KiB',
                           size_bytes: 119_808, uuid: '88077904-4fd4-476f-9af2-0f7a806ca25e' },
          '/dev/sda2' => { size: '98.25 MiB', size_bytes: 103_021_056 } }
      end

      before do
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/device").and_return(true)
        allow(Dir).to receive(:[]).with("#{sys_block_path}/sda/**/*").and_return(sda_subdirs)
        sda_subdirs.each { |subdir| allow(File).to receive(:directory?).with(subdir).and_return(true) }
        allow(File).to receive(:readable?).with("#{sys_block_path}/sda/sda2/size").and_return(true)
        allow(File).to receive(:read).with("#{sys_block_path}/sda/sda2/size").and_return('201213')
        allow(File).to receive(:readable?).with("#{sys_block_path}/sda/sda1/size").and_return(true)
        allow(File).to receive(:read).with("#{sys_block_path}/sda/sda1/size").and_return('234')
        allow(Open3).to receive(:capture3).with('which blkid').and_return('/usr/bin/blkid')
        allow(Open3).to receive(:capture3).with('blkid').and_return(load_fixture('blkid_output').read)
      end

      it 'return partitions fact' do
        expect(resolver.resolve(:partitions)).to eq(partitions)
      end
    end

    context 'when block has a dm subdir' do
      let(:partitions) do
        { '/dev/mapper/VolGroup00-LogVol00' => { filesystem: 'ext3', size: '98.25 MiB', size_bytes: 103_021_056,
                                                 uuid: '1bd8643b-483a-4fdc-adcd-c586384919a8' } }
      end

      before do
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/device").and_return(false)
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/dm").and_return(true)
        allow(File).to receive(:readable?).with("#{sys_block_path}/sda/dm/name").and_return(true)
        allow(File).to receive(:read).with("#{sys_block_path}/sda/dm/name").and_return('VolGroup00-LogVol00')

        allow(File).to receive(:readable?).with("#{sys_block_path}/sda/size").and_return(true)
        allow(File).to receive(:read).with("#{sys_block_path}/sda/size").and_return('201213')
        allow(Open3).to receive(:capture3).with('which blkid').and_return('/usr/bin/blkid')
        allow(Open3).to receive(:capture3).with('blkid').and_return(load_fixture('blkid_output').read)
      end

      it 'return partitions fact' do
        expect(resolver.resolve(:partitions)).to eq(partitions)
      end
    end

    context 'when block has a loop subdir' do
      let(:partitions) do
        { '/dev//sys/block/sda' => { backing_file: 'some_path', size: '98.25 MiB', size_bytes: 103_021_056 } }
      end

      before do
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/device").and_return(false)
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/dm").and_return(false)
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/loop").and_return(true)
        allow(File).to receive(:readable?).with("#{sys_block_path}/sda/loop/backing_file").and_return(true)
        allow(File).to receive(:read).with("#{sys_block_path}/sda/loop/backing_file").and_return('some_path')

        allow(File).to receive(:readable?).with("#{sys_block_path}/sda/size").and_return(true)
        allow(File).to receive(:read).with("#{sys_block_path}/sda/size").and_return('201213')
        allow(Open3).to receive(:capture3).with('which blkid').and_return('/usr/bin/blkid')
        allow(Open3).to receive(:capture3).with('blkid').and_return(load_fixture('blkid_output').read)
      end

      it 'return partitions fact' do
        expect(resolver.resolve(:partitions)).to eq(partitions)
      end
    end
  end
end
