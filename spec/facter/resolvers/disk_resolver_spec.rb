# frozen_string_literal: true

describe 'DiskResolver' do
  describe '#resolve' do
    before do
      allow(File).to receive(:exist?).with(path).and_return(true)
      allow(File).to receive(:read).with(path).and_return(file_content)
    end
    after do
      Facter::Resolvers::Linux::Disk.invalidate_cache
    end
    context 'when sr0_model exists' do
      let(:file_content) { 'VMware IDE CDR00' }
      let(:path) { '/sys/block/sr0/device/model' }
      it 'returns sr0_model' do
        result = Facter::Resolvers::Linux::Disk.resolve(:sr0_model)

        expect(result).to eq(file_content)
      end
    end
    context 'when sr0_size exists' do
      let(:file_content) { '1073741312' }
      let(:path) { '/sys/block/sr0/size' }
      it 'returns sr0_size' do
        result = Facter::Resolvers::Linux::Disk.resolve(:sr0_size)

        expect(result).to eq(file_content.to_i * 1024)
      end
    end
    context 'when sr0_vendor exists' do
      let(:file_content) { 'NECVMWar' }
      let(:path) { '/sys/block/sr0/device/vendor' }
      it 'returns sr0_vendor' do
        result = Facter::Resolvers::Linux::Disk.resolve(:sr0_vendor)

        expect(result).to eq(file_content)
      end
    end
    context 'when sda_model exists' do
      let(:file_content) { 'Virtual disk' }
      let(:path) { '/sys/block/sda/device/model' }
      it 'returns sda_model' do
        result = Facter::Resolvers::Linux::Disk.resolve(:sda_model)

        expect(result).to eq(file_content)
      end
    end
    context 'when sda_size exists' do
      let(:file_content) { '21474836480' }
      let(:path) { '/sys/block/sda/size' }
      it 'returns sda_size' do
        result = Facter::Resolvers::Linux::Disk.resolve(:sda_size)

        expect(result).to eq(file_content.to_i * 1024)
      end
    end
    context 'when sda_vendor exists' do
      let(:file_content) { 'VMware' }
      let(:path) { '/sys/block/sda/device/vendor' }
      it 'returns sda_vendor' do
        result = Facter::Resolvers::Linux::Disk.resolve(:sda_vendor)

        expect(result).to eq(file_content)
      end
    end
  end
end
