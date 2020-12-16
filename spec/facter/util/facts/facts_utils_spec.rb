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
end
