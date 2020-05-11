# frozen_string_literal: true

describe Facter::Resolvers::Windows::Fips do
  describe '#resolve' do
    let(:reg) { instance_double('Win32::Registry::HKEY_LOCAL_MACHINE') }

    before do
      allow(reg).to receive(:close)
      allow(reg).to receive(:[]).with('Enabled').and_return(is_fips)
      allow(reg).to receive(:any?).and_yield('Enabled', '1')
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open)
        .with('System\\CurrentControlSet\\Control\\Lsa\\FipsAlgorithmPolicy').and_return(reg)
    end

    after do
      Facter::Resolvers::Windows::Fips.invalidate_cache
    end

    context 'when field exists in registry' do
      let(:is_fips) { 255 }

      it 'detects that fips is enabled' do
        expect(Facter::Resolvers::Windows::Fips.resolve(:fips_enabled)).to be(true)
      end
    end

    context "when field doesn't exists in registry" do
      let(:is_fips) { 0 }

      it "detects that fips isn't enabled" do
        expect(Facter::Resolvers::Windows::Fips.resolve(:fips_enabled)).to be(false)
      end
    end
  end
end
