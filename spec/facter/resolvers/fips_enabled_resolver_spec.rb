# frozen_string_literal: true

describe Facter::Resolvers::Linux::FipsEnabled do
  describe '#resolve' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)\
        .with('/proc/sys/crypto/fips_enabled').and_return(file_content)
    end

    after do
      Facter::Resolvers::Linux::FipsEnabled.invalidate_cache
    end

    context 'when fips is not enabled' do
      let(:file_content) { '0' }

      it 'returns fips is not enabled' do
        result = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)

        expect(result).to eq('false')
      end
    end

    context 'when fips_enabled file is missing' do
      let(:file_content) { '' }

      it 'returns fips is not enabled' do
        result = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)

        expect(result).to eq('false')
      end
    end

    context 'when fips is enabled' do
      let(:file_content) { '1' }

      it 'returns fips is enabled' do
        result = Facter::Resolvers::Linux::FipsEnabled.resolve(:fips_enabled)

        expect(result).to eq('true')
      end
    end
  end
end
