# frozen_string_literal: true

describe Facter::Resolvers::Partitions do
  subject(:resolver) { Facter::Resolvers::Partitions }

  let(:sys_block_path) { '/sys/block' }
  let(:sys_block_subdirs) { ['.', '..', 'sda'] }
  let(:logger) { instance_spy(Facter::Log) }

  before do
    Facter::Resolvers::Partitions.invalidate_cache
    Facter::Resolvers::Partitions.instance_variable_set(:@log, logger)
  end

  context 'when /sys/block is not readable' do
    before do
      allow(File).to receive(:readable?).with(sys_block_path).and_return(false)
    end

    it 'returns empty hash' do
      expect(resolver.resolve(:partitions)).to be(nil)
    end
  end

  context 'when /sys/block has no entries' do
    before do
      allow(File).to receive(:readable?).with(sys_block_path).and_return(true)
      allow(Dir).to receive(:entries).with(sys_block_path).and_return(['.', '..'])
    end

    it 'returns empty hash' do
      expect(resolver.resolve(:partitions)).to be(nil)
    end
  end

  context 'when /sys/block is readable' do
    before do
      allow(File).to receive(:readable?).with(sys_block_path).and_return(true)
      allow(Dir).to receive(:entries).with(sys_block_path).and_return(sys_block_subdirs)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('which blkid', logger: logger).and_return('/usr/bin/blkid')
      allow(Facter::Core::Execution).to receive(:execute)
        .with('blkid', logger: logger).and_return(load_fixture('blkid_output').read)
      allow(Facter::Core::Execution).to receive(:execute)
        .with('which lsblk', logger: logger).and_return('/usr/bin/lsblk')
      allow(Facter::Core::Execution).to receive(:execute)
        .with('lsblk -fp', logger: logger).and_return(load_fixture('lsblk_output').read)
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

      before do
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/device").and_return(true)
        allow(Dir).to receive(:[]).with("#{sys_block_path}/sda/**/*").and_return(sda_subdirs)
        sda_subdirs.each { |subdir| allow(File).to receive(:directory?).with(subdir).and_return(true) }
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with("#{sys_block_path}/sda/sda2/size", '0').and_return('201213')
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with("#{sys_block_path}/sda/sda1/size", '0').and_return('234')
      end

      context 'when device size files are readable' do
        let(:partitions) do
          { '/dev/sda1' => { filesystem: 'ext3', label: '/boot', size: '117.00 KiB',
                             size_bytes: 119_808, uuid: '88077904-4fd4-476f-9af2-0f7a806ca25e',
                             partuuid: '00061fe0-01' },
            '/dev/sda2' => { filesystem: 'LVM2_member', size: '98.25 MiB', size_bytes: 103_021_056,
                             uuid: 'edi7s0-2WVa-ZBan' } }
        end

        it 'return partitions fact' do
          expect(resolver.resolve(:partitions)).to eq(partitions)
        end
      end

      context 'when device size files are not readable' do
        let(:partitions_with_no_sizes) do
          { '/dev/sda1' => { filesystem: 'ext3', label: '/boot', size: '0 bytes',
                             size_bytes: 0, uuid: '88077904-4fd4-476f-9af2-0f7a806ca25e', partuuid: '00061fe0-01' },
            '/dev/sda2' => { filesystem: 'LVM2_member', size: '0 bytes', size_bytes: 0, uuid: 'edi7s0-2WVa-ZBan' } }
        end

        before do
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with("#{sys_block_path}/sda/sda2/size", '0').and_return('')
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with("#{sys_block_path}/sda/sda1/size", '0').and_return('')
        end

        it 'return partitions fact with 0 sizes' do
          result = resolver.resolve(:partitions)

          expect(result).to eq(partitions_with_no_sizes)
        end
      end
    end

    context 'when block has a dm subdir' do
      before do
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/device").and_return(false)
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/dm").and_return(true)
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with("#{sys_block_path}/sda/dm/name").and_return('VolGroup00-LogVol00')
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with("#{sys_block_path}/sda/size", '0').and_return('201213')
      end

      context 'when device name file is readable' do
        let(:partitions) do
          { '/dev/mapper/VolGroup00-LogVol00' => { filesystem: 'ext3', size: '98.25 MiB', size_bytes: 103_021_056,
                                                   uuid: '1bd8643b-483a-4fdc-adcd-c586384919a8' } }
        end

        it 'return partitions fact' do
          expect(resolver.resolve(:partitions)).to eq(partitions)
        end
      end

      context 'when device name file is not readable' do
        let(:partitions) do
          { '/dev/sys/block/sda' => { size: '98.25 MiB', size_bytes: 103_021_056 } }
        end

        before do
          allow(Facter::Util::FileHelper).to receive(:safe_read).with("#{sys_block_path}/sda/dm/name").and_return('')
        end

        it 'return partitions fact with no device name' do
          result = resolver.resolve(:partitions)

          expect(result).to eq(partitions)
        end
      end
    end

    context 'when block has a loop subdir' do
      before do
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/device").and_return(false)
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/dm").and_return(false)
        allow(File).to receive(:directory?).with("#{sys_block_path}/sda/loop").and_return(true)
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with("#{sys_block_path}/sda/loop/backing_file").and_return('some_path')
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with("#{sys_block_path}/sda/size", '0').and_return('201213')
      end

      context 'when backing_file is readable' do
        let(:partitions) do
          { '/dev/sys/block/sda' => { backing_file: 'some_path', size: '98.25 MiB', size_bytes: 103_021_056 } }
        end

        it 'returns partitions fact' do
          expect(resolver.resolve(:partitions)).to eq(partitions)
        end
      end

      context 'when backing_file is not readable' do
        let(:partitions) do
          { '/dev/sys/block/sda' => { size: '98.25 MiB', size_bytes: 103_021_056 } }
        end

        before do
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with("#{sys_block_path}/sda/loop/backing_file").and_return('')
        end

        it 'returns partitions fact' do
          result = resolver.resolve(:partitions)

          expect(result).to eq(partitions)
        end
      end
    end
  end
end
