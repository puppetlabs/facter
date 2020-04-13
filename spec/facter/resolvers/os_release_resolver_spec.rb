# frozen_string_literal: true

describe Facter::Resolvers::OsRelease do
  context 'when /etc/os-release file is readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/etc/os-release')
        .and_return(load_fixture('os_release').readlines)
    end

    after do
      Facter::Resolvers::OsRelease.invalidate_cache
    end

    it 'returns os NAME' do
      result = Facter::Resolvers::OsRelease.resolve(:name)

      expect(result).to eq('Ubuntu')
    end

    it 'returns os PRETTY_NAME' do
      result = Facter::Resolvers::OsRelease.resolve(:pretty_name)

      expect(result).to eq('Ubuntu 18.04.1 LTS')
    end

    it 'returns os VERSION_ID' do
      result = Facter::Resolvers::OsRelease.resolve(:version_id)

      expect(result).to eq('18.04')
    end

    it 'returns os VERSION_CODENAME' do
      result = Facter::Resolvers::OsRelease.resolve(:version_codename)

      expect(result).to eq('bionic')
    end
  end

  context 'when /etc/os-release file is not readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/etc/os-release')
        .and_return([])
    end

    it 'returns nil' do
      result = Facter::Resolvers::OsRelease.resolve(:version_codename)

      expect(result).to be(nil)
    end
  end
end
