# frozen_string_literal: true

describe Facter::Resolvers::OsRelease do
  after do
    Facter::Resolvers::OsRelease.invalidate_cache
  end

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_readlines)
      .with('/etc/os-release')
      .and_return(os_release_content)
  end

  context 'when on Ubuntu' do
    let(:os_release_content) { load_fixture('os_release').readlines }

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

    it 'returns os identifier' do
      result = Facter::Resolvers::OsRelease.resolve(:identifier)

      expect(result).to eq('')
    end
  end

  context 'when /etc/os-release file is not readable' do
    let(:os_release_content) { [] }

    it 'returns nil' do
      result = Facter::Resolvers::OsRelease.resolve(:version_codename)

      expect(result).to be(nil)
    end
  end

  context 'when on Debian' do
    let(:os_release_content) { load_fixture('os_release_debian').readlines }

    it 'returns os NAME' do
      result = Facter::Resolvers::OsRelease.resolve(:name)

      expect(result).to eq('Debian')
    end

    it 'returns os PRETTY_NAME' do
      result = Facter::Resolvers::OsRelease.resolve(:pretty_name)

      expect(result).to eq('Debian GNU/Linux 10 (buster)')
    end

    it 'returns os VERSION_ID with padded 0' do
      result = Facter::Resolvers::OsRelease.resolve(:version_id)

      expect(result).to eq('10.0')
    end

    it 'returns os VERSION_CODENAME' do
      result = Facter::Resolvers::OsRelease.resolve(:version_codename)

      expect(result).to eq('buster')
    end

    it 'returns os identifier' do
      result = Facter::Resolvers::OsRelease.resolve(:identifier)

      expect(result).to eq('debian')
    end
  end

  context 'when on opensuse-leap' do
    let(:os_release_content) { load_fixture('os_release_opensuse-leap').readlines }

    it 'returns os identifier' do
      result = Facter::Resolvers::OsRelease.resolve(:identifier)

      expect(result).to eq('opensuse')
    end

    context 'when opensuse identifier is capitalized' do
      it 'returns os identifier' do
        os_release_content[2] = 'ID="Opensuse-Leap"'

        result = Facter::Resolvers::OsRelease.resolve(:identifier)

        expect(result).to eq('opensuse')
      end
    end
  end

  context 'when on Oracle Linux' do
    let(:os_release_content) { load_fixture('os_release_oracle_linux').readlines }

    it 'returns os NAME' do
      result = Facter::Resolvers::OsRelease.resolve(:name)

      expect(result).to eq('OracleLinux')
    end
  end
end
