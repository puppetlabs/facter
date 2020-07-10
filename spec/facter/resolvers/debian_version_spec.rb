# frozen_string_literal: true

describe Facter::Resolvers::DebianVersion do
  after do
    Facter::Resolvers::DebianVersion.invalidate_cache
  end

  context 'when file debian_version is readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/debian_version').and_return("10.01\n")
    end

    it 'returns version' do
      result = Facter::Resolvers::DebianVersion.resolve(:version)

      expect(result).to eq('10.01')
    end
  end

  context 'when file debian_version is not readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read).with('/etc/debian_version').and_return('')
    end

    it 'returns nil' do
      result = Facter::Resolvers::DebianVersion.resolve(:version)

      expect(result).to be(nil)
    end
  end
end
