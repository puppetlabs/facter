# frozen_string_literal: true

describe Facter::Resolvers::Aix::Filesystem do
  let(:filesystems) { 'ahafs,cdrfs,namefs,procfs,sfs' }

  after do
    Facter::Resolvers::Aix::Filesystem.invalidate_cache
  end

  context 'when vfs file is readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/etc/vfs')
        .and_return(load_fixture('aix_filesystems').readlines)
    end

    it 'returns filesystems' do
      result = Facter::Resolvers::Aix::Filesystem.resolve(:file_systems)

      expect(result).to eq(filesystems)
    end
  end

  context 'when vfs file is not readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/etc/vfs')
        .and_return([])
    end

    it 'returns nil' do
      result = Facter::Resolvers::Aix::Filesystem.resolve(:file_systems)

      expect(result).to be(nil)
    end
  end
end
