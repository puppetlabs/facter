# frozen_string_literal: true

describe 'SuseReleaseResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('cat /etc/SuSE-release')
      .and_return("openSUSE 11.1 (i586)
        VERSION = 11.1")
  end

  it 'returns os NAME' do
    result = Facter::Resolver::SuseReleaseResolver.resolve(:name)

    expect(result).to eq('openSUSE')
  end

  it 'returns os VERSION_ID' do
    result = Facter::Resolver::SuseReleaseResolver.resolve(:version)

    expect(result).to eq('11.1')
  end

  it 'returns the identifier' do
    result = Facter::Resolver::SuseReleaseResolver.resolve(:identifier)

    expect(result).to eq('opensuse')
  end
end
