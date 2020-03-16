# frozen_string_literal: true

describe Facter::Resolvers::LsbRelease do
  after do
    Facter::Resolvers::LsbRelease.invalidate_cache
  end

  context 'when system is ubuntu' do
    before do
      allow(Open3).to receive(:capture3)
        .with('which lsb_release')
        .and_return(['/usr/bin/lsb_release', '', 0])
      allow(Open3).to receive(:capture3)
        .with('lsb_release -a')
        .and_return(["Distributor ID:\tUbuntu\nDescription:\tUbuntu 18.04.1 LTS\nRelease:\t18.04\nCodename:\tbionic\n",
                     '', 0])
    end

    it 'returns os Distributor ID' do
      result = Facter::Resolvers::LsbRelease.resolve(:distributor_id)

      expect(result).to eq('Ubuntu')
    end

    it 'returns distro Description' do
      result = Facter::Resolvers::LsbRelease.resolve(:description)

      expect(result).to eq('Ubuntu 18.04.1 LTS')
    end

    it 'returns distro release' do
      result = Facter::Resolvers::LsbRelease.resolve(:release)

      expect(result).to eq('18.04')
    end

    it 'returns distro Codename' do
      result = Facter::Resolvers::LsbRelease.resolve(:codename)

      expect(result).to eq('bionic')
    end
  end

  context 'when system is centos' do
    before do
      allow(Open3).to receive(:capture3)
        .with('which lsb_release')
        .and_return(['/usr/bin/lsb_release', '', 0])
      allow(Open3).to receive(:capture3)
        .with('lsb_release -a')
        .and_return([load_fixture('centos_lsb_release').read, '', 0])
    end

    it 'returns distro Distributor ID' do
      result = Facter::Resolvers::LsbRelease.resolve(:distributor_id)

      expect(result).to eq('CentOS')
    end

    it 'returns distro Description' do
      result = Facter::Resolvers::LsbRelease.resolve(:description)

      expect(result).to eq('CentOS Linux release 7.2.1511 (Core)')
    end

    it 'returns distro release' do
      result = Facter::Resolvers::LsbRelease.resolve(:release)

      expect(result).to eq('7.2.1511')
    end

    it 'returns distro lsb release' do
      result = Facter::Resolvers::LsbRelease.resolve(:lsb_version)

      expect(result).to eq(':core-4.1-amd64:core-4.1-noarch:cxx-4.1-amd64:cxx-4.1-noarch:desktop-4.1-amd64')
    end

    it 'returns distro Codename' do
      result = Facter::Resolvers::LsbRelease.resolve(:codename)

      expect(result).to eq('Core')
    end
  end

  context 'when lsb_release is not installed on system' do
    before do
      allow(Open3).to receive(:capture3)
        .with('which lsb_release')
        .and_return(['', 'no lsb_release in (PATH:usr/sbin)', 1])
    end

    it 'returns distro Distributor ID as nil' do
      result = Facter::Resolvers::LsbRelease.resolve(:distributor_id)

      expect(result).to eq(nil)
    end

    it 'returns that lsb_release is not installed' do
      result = Facter::Resolvers::LsbRelease.resolve(:lsb_release_installed)

      expect(result).to be_falsey
    end
  end
end
