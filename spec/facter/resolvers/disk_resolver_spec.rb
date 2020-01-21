# frozen_string_literal: true

describe 'DiskResolver' do
  context '#resolve' do
    let(:paths) { { model: '/device/model', size: '/size', vendor: '/device/vendor' } }
    let(:disks) { %w[sr0 sda] }
    let(:size) { '41943040' }
    let(:expected_output) { { 'sda' => { size: size.to_i * 512 }, 'sr0' => { size: size.to_i * 512 } } }
    subject(:resolver) { Facter::Resolvers::Linux::Disk }
    before do
      allow(Dir).to receive(:entries).with('/sys/block').and_return(['.', '..', 'sr0', 'sda'])
      allow(File).to receive(:exist?).with('/sys/block/sr0/size').and_return(true)
      allow(File).to receive(:exist?).with('/sys/block/sda/size').and_return(true)
      paths.each do |_key, value|
        disks.each do |disk|
          allow(File).to receive(:exist?).with("/sys/block/#{disk}#{value}").and_return(false) unless value =~ /size/
        end
      end
      allow(File).to receive(:read).and_return(size)
    end
    after do
      Facter::Resolvers::Linux::Disk.invalidate_cache
    end

    it 'returns disks fact' do
      expect(resolver.resolve(:disks)).to eql(expected_output)
    end
  end
end
