# frozen_string_literal: true

describe Facter::Util::Facts do
  subject(:facts_util) { Facter::Util::Facts }

  describe '#discover_family' do
    it "discovers Fedora's family" do
      expect(facts_util.discover_family('rhel fedora')).to eq('RedHat')
    end

    it "discovers Centos's family" do
      expect(facts_util.discover_family('rhel fedora centos')).to eq('RedHat')
    end

    it "discovers PSBM's family" do
      expect(facts_util.discover_family('PSBM')).to eq('RedHat')
    end

    it "discovers Virtuozzo's family" do
      expect(facts_util.discover_family('VirtuozzoLinux')).to eq('RedHat')
    end

    it "discovers SLED's family" do
      expect(facts_util.discover_family('SLED')).to eq('Suse')
    end

    it "discovers KDE's family" do
      expect(facts_util.discover_family('KDE')).to eq('Debian')
    end

    it "discovers HuaweiOS's family" do
      expect(facts_util.discover_family('HuaweiOS')).to eq('Debian')
    end

    it "discovers Gentoo's family" do
      expect(facts_util.discover_family('gentoo')).to eq('Gentoo')
    end

    it "discovers Manjaro's family" do
      expect(facts_util.discover_family('Manjaro')).to eq('Archlinux')
    end

    it "discovers Mandriva's family" do
      expect(facts_util.discover_family('Mandriva')).to eq('Mandrake')
    end
  end

  describe '#release_hash_from_string' do
    it 'returns full release' do
      expect(facts_util.release_hash_from_string('6.2')['full']).to eq('6.2')
    end

    it 'returns major release' do
      expect(facts_util.release_hash_from_string('6.2')['major']).to eq('6')
    end

    it 'returns valid minor release' do
      expect(facts_util.release_hash_from_string('6.2.1')['minor']).to eq('2')
    end

    it 'returns minor release as nil' do
      expect(facts_util.release_hash_from_string('6')['minor']).to be_nil
    end

    it 'returns nil if data is nil' do
      expect(facts_util.release_hash_from_string(nil)).to be_nil
    end
  end

  describe '#release_hash_from_matchdata' do
    let(:match_data) do
      'RELEASE=4.3' =~ /^RELEASE=(\d+.\d+.*)/
      Regexp.last_match
    end

    it 'returns full release' do
      expect(facts_util.release_hash_from_matchdata(match_data)['full']).to eq('4.3')
    end

    it 'returns major release' do
      expect(facts_util.release_hash_from_matchdata(match_data)['major']).to eq('4')
    end

    it 'returns valid minor release' do
      expect(facts_util.release_hash_from_matchdata(match_data)['minor']).to eq('3')
    end

    it 'returns nil if data is nil' do
      expect(facts_util.release_hash_from_matchdata(nil)).to be_nil
    end

    context 'when minor version is unavailable' do
      let(:match_data) do
        'RELEASE=4' =~ /^RELEASE=(\d+)/
        Regexp.last_match
      end

      it 'returns minor release as nil' do
        expect(facts_util.release_hash_from_matchdata(match_data)['minor']).to be_nil
      end
    end
  end
end
