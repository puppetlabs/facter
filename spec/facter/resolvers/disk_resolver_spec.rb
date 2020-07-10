# frozen_string_literal: true

describe Facter::Resolvers::Linux::Disk do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Linux::Disk }

    let(:disk_files) { %w[sr0/device sr0/size sda/device sda/size] }
    let(:paths) { { model: '/device/model', size: '/size', vendor: '/device/vendor' } }
    let(:disks) { %w[sr0 sda] }
    let(:size) { '12' }
    let(:model) { 'test' }

    before do
      allow(Dir).to receive(:entries).with('/sys/block').and_return(['.', '..', 'sr0', 'sda'])
    end

    after do
      Facter::Resolvers::Linux::Disk.invalidate_cache
    end

    context 'when device dir for blocks exists' do
      let(:expected_output) do
        { 'sda' => { model: 'test', size: '6.00 KiB', size_bytes: 6144, vendor: 'test' },
          'sr0' => { model: 'test', size: '6.00 KiB', size_bytes: 6144, vendor: 'test' } }
      end

      before do
        disk_files.each do |disk_file|
          allow(File).to receive(:readable?).with("/sys/block/#{disk_file}").and_return(true)
        end
        paths.each do |_key, value|
          disks.each do |disk|
            if value == '/size'
              allow(Facter::Util::FileHelper).to receive(:safe_read)
                .with("/sys/block/#{disk}#{value}").and_return(size)
            else
              allow(Facter::Util::FileHelper).to receive(:safe_read)
                .with("/sys/block/#{disk}#{value}").and_return(model)
            end
          end
        end
      end

      context 'when all files are readable' do
        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end

      context 'when size files are not readable' do
        let(:expected_output) do
          { 'sda' => { model: 'test', vendor: 'test' },
            'sr0' => { model: 'test', vendor: 'test' } }
        end

        before do
          paths.each do |_key, value|
            disks.each do |disk|
              if value == '/size'
                allow(Facter::Util::FileHelper).to receive(:safe_read)
                  .with("/sys/block/#{disk}#{value}").and_return('')
              end
            end
          end
        end

        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end

      context 'when device vendor and model files are not readable' do
        let(:expected_output) do
          { 'sda' => { size: '6.00 KiB', size_bytes: 6144 },
            'sr0' => { size: '6.00 KiB', size_bytes: 6144 } }
        end

        before do
          paths.each do |_key, value|
            disks.each do |disk|
              if value != '/size'
                allow(Facter::Util::FileHelper).to receive(:safe_read)
                  .with("/sys/block/#{disk}#{value}").and_return('')
              end
            end
          end
        end

        it 'returns disks fact' do
          expect(resolver.resolve(:disks)).to eql(expected_output)
        end
      end
    end

    context 'when all files inside device dir for blocks are missing' do
      before do
        disk_files.each do |disk_file|
          allow(File).to receive(:readable?).with("/sys/block/#{disk_file}").and_return(false)
        end
      end

      it 'returns disks fact as nil' do
        expect(resolver.resolve(:disks)).to be(nil)
      end
    end
  end
end
