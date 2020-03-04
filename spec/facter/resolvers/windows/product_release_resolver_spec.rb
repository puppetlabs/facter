# frozen_string_literal: true

describe Facter::Resolvers::ProductRelease do
  describe '#resolve' do
    context 'when all fields exist in registry' do
      let(:reg) { { 'EditionID' => ed, 'InstallationType' => install, 'ProductName' => prod, 'ReleaseId' => release } }
      let(:ed) { 'ServerStandard' }
      let(:install) { 'Server' }
      let(:prod) { 'Windows Server 2019 Standard' }
      let(:release) { '1809' }

      before do
        allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open)
          .with('SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion')
          .and_return(reg)
        allow(reg).to receive(:[]).with('EditionID').and_return(ed)
        allow(reg).to receive(:[]).with('InstallationType').and_return(install)
        allow(reg).to receive(:[]).with('ProductName').and_return(prod)
        allow(reg).to receive(:[]).with('ReleaseId').and_return(release)
        allow(reg).to receive(:close)
      end

      after do
        Facter::Resolvers::ProductRelease.invalidate_cache
      end

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
      let(:reg) { { 'EditionID' => ed, 'ProductName' => prod, 'ReleaseId' => release } }
      let(:ed) { 'ServerStandard' }
      let(:prod) { 'Windows Server 2019 Standard' }
      let(:release) { '1809' }

      before do
        allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open)
          .with('SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion')
          .and_return(reg)
        allow(reg).to receive(:[]).with('EditionID').and_return(ed)
        allow(reg).to receive(:[]).with('ProductName').and_return(prod)
        allow(reg).to receive(:[]).with('ReleaseId').and_return(release)
        allow(reg).to receive(:close)
      end

      after do
        Facter::Resolvers::ProductRelease.invalidate_cache
      end

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
