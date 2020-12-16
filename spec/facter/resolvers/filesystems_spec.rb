# frozen_string_literal: true

describe Facter::Resolvers::Linux::Filesystems do
  let(:systems) { 'ext2,ext3,ext4,xfs' }

  after do
    Facter::Resolvers::Linux::Filesystems.invalidate_cache
  end

  context 'when filesystems is readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/proc/filesystems', nil)
        .and_return(load_fixture('filesystems').readlines)
    end

    it 'returns systems' do
      result = Facter::Resolvers::Linux::Filesystems.resolve(:systems)

      expect(result).to eq(systems)
    end
  end

  context 'when filesystems is not readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/proc/filesystems', nil).and_return(nil)
    end

    it 'returns nil' do
      result = Facter::Resolvers::Linux::Filesystems.resolve(:systems)

      expect(result).to be(nil)
    end
  end
end
