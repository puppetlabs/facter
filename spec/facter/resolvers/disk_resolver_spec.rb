# frozen_string_literal: true

describe Facter::Resolvers::Linux::Disk do
  describe '#resolve' do
    after do
      Facter::Resolvers::Linux::Disk.invalidate_cache
    end

    context 'when device dir for blocks are missing' do
      subject(:resolver) { Facter::Resolvers::Linux::Disk }

      let(:paths) { { model: '/device/model', size: '/size', vendor: '/device/vendor' } }
      let(:disks) { %w[sr0 sda] }
      let(:size) { '41943040' }
      let(:expected_output) { nil }

      before do
        allow(Dir).to receive(:entries).with('/sys/block').and_return(['.', '..', 'sr0', 'sda'])
        allow(File).to receive(:readable?).with('/sys/block/sr0/device').and_return(false)
        allow(File).to receive(:readable?).with('/sys/block/sda/device').and_return(false)
        allow(File).to receive(:read).and_return(size)
      end

      it 'returns disks fact as nil' do
        expect(resolver.resolve(:disks)).to eql(expected_output)
      end
    end

    context 'when there are device dir for blocks' do
      subject(:resolver) { Facter::Resolvers::Linux::Disk }

      let(:paths) { { model: '/device/model', size: '/size', vendor: '/device/vendor' } }
      let(:disks) { %w[sr0 sda] }
      let(:size) { 'test' }
      let(:expected_output) do
        { 'sda' => { model: 'test', size: '0 bytes', size_bytes: 0, vendor: 'test' },
          'sr0' => { model: 'test', size: '0 bytes', size_bytes: 0, vendor: 'test' } }
      end

      before do
        allow(Dir).to receive(:entries).with('/sys/block').and_return(['.', '..', 'sr0', 'sda'])
        allow(File).to receive(:readable?).with('/sys/block/sr0/device').and_return(true)
        allow(File).to receive(:readable?).with('/sys/block/sda/device').and_return(true)
        allow(File).to receive(:readable?).with('/sys/block/sr0/size').and_return(true)
        allow(File).to receive(:readable?).with('/sys/block/sda/size').and_return(true)
        paths.each do |_key, value|
          disks.each do |disk|
            allow(File).to receive(:readable?).with("/sys/block/#{disk}#{value}").and_return(true)
          end
        end
        allow(File).to receive(:read).and_return(size)
      end

      it 'returns disks fact as nil' do
        expect(resolver.resolve(:disks)).to eql(expected_output)
      end
    end
  end
end
