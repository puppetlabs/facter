# frozen_string_literal: true

describe 'Windows Fips' do
  describe '#resolve' do
    let(:reg) { { 'Enabled' => is_fips } }
    before do
      allow(Win32::Registry::HKEY_LOCAL_MACHINE).to receive(:open)
        .with('System\\CurrentControlSet\\Control\\Lsa\\FipsAlgorithmPolicy').and_return(reg)
      allow(reg).to receive(:close)
    end

    after do
      Facter::Resolvers::Windows::Fips.invalidate_cache
    end

    context 'when field exists in registry' do
      let(:is_fips) { 255 }

      it 'detects that fips is enabled' do
        expect(Facter::Resolvers::Windows::Fips.resolve(:fips_enabled)).to eql(true)
      end
    end

    context 'when field exists in registry' do
      let(:is_fips) { 0 }

      it "detects that fips isn't enabled" do
        expect(Facter::Resolvers::Windows::Fips.resolve(:fips_enabled)).to eql(false)
      end
    end
  end
end
