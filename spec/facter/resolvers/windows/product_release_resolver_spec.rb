# frozen_string_literal: true

describe Facter::Resolvers::ProductRelease do
  describe '#resolve' do
    let(:reg) { instance_double('Win32::Registry::HKEY_LOCAL_MACHINE') }
    let(:ed) { 'ServerStandard' }
    let(:install) { 'Server' }
    let(:prod) { 'Windows Server 2019 Standard' }
    let(:release) { '1809' }

    before do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open)
        .with('SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion')
        .and_return(reg)
      allow(reg).to receive(:each)
        .and_yield('EditionID', ed)
        .and_yield('InstallationType', install)
        .and_yield('ProductName', prod)
        .and_yield('ReleaseId', release)

      allow(reg).to receive(:[]).with('EditionID').and_return(ed)
      allow(reg).to receive(:[]).with('InstallationType').and_return(install)
      allow(reg).to receive(:[]).with('ProductName').and_return(prod)
      allow(reg).to receive(:[]).with('ReleaseId').and_return(release)

      allow(reg).to receive(:close)
    end

    after do
      Facter::Resolvers::ProductRelease.invalidate_cache
    end

    context 'when all fields exist in registry' do
      it 'detects edition id' do
        expect(Facter::Resolvers::ProductRelease.resolve(:edition_id)).to eql(ed)
      end

      it 'detects installation type' do
        expect(Facter::Resolvers::ProductRelease.resolve(:installation_type)).to eql(install)
      end

      it 'detects product name' do
        expect(Facter::Resolvers::ProductRelease.resolve(:product_name)).to eql(prod)
      end

      it 'detects release id' do
        expect(Facter::Resolvers::ProductRelease.resolve(:release_id)).to eql(release)
      end
    end

    context "when InstallationType doen't exist in registry" do
      let(:install) { nil }

      it 'detects edition id' do
        expect(Facter::Resolvers::ProductRelease.resolve(:edition_id)).to eql(ed)
      end

      it 'detects installation type as nil' do
        expect(Facter::Resolvers::ProductRelease.resolve(:installation_type)).to be(nil)
      end

      it 'detects product name' do
        expect(Facter::Resolvers::ProductRelease.resolve(:product_name)).to eql(prod)
      end

      it 'detects release id' do
        expect(Facter::Resolvers::ProductRelease.resolve(:release_id)).to eql(release)
      end
    end
  end
end
