# frozen_string_literal: true

describe Facter::Resolvers::SuseRelease do
  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/etc/SuSE-release', nil)
      .and_return("openSUSE 11.1 (i586)
        VERSION = 11.1")
  end

  it 'returns os NAME' do
    result = Facter::Resolvers::SuseRelease.resolve(:name)

    expect(result).to eq('openSUSE')
  end

  it 'returns os VERSION_ID' do
    result = Facter::Resolvers::SuseRelease.resolve(:version)

    expect(result).to eq('11.1')
  end

  it 'returns the identifier' do
    result = Facter::Resolvers::SuseRelease.resolve(:identifier)

    expect(result).to eq('opensuse')
  end
end
