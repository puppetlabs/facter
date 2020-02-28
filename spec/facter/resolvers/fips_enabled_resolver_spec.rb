# frozen_string_literal: true

describe Facter::Resolvers::Linux::FipsEnabled do
  describe '#resolve' do
    before do
      allow(File).to receive(:directory?).with('/proc/sys/crypto').and_return(dir_exists)
      allow(File).to receive(:read).with('/proc/sys/crypto/fips_enabled').and_return(file_content)

      Facter::Resolvers::Linux::FipsEnabled.invalidate_cache
    end

    context 'when fips is not enabled' do
      let(:file_content) { '0' }
      let(:dir_exists) { true }

      it 'returns fips is not enabled' do
        result = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)

        expect(result).to eq(false)
      end
    end

    context 'when fips is not enabled and crypto dir is missing' do
      let(:file_content) { nil }
      let(:dir_exists) { false }

      it 'returns fips is not enabled' do
        result = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)

        expect(result).to eq(false)
      end
    end

    context 'when fips is enabled' do
      let(:file_content) { '1' }
      let(:dir_exists) { true }

      it 'returns fips is enabled' do
        result = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)

        expect(result).to eq(true)
      end
    end
  end
end
