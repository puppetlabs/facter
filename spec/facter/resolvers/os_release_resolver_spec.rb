# frozen_string_literal: true

describe 'OsReleaseResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('cat /etc/os-release')
      .and_return(load_fixture('os_release').read)
  end

  it 'returns os NAME' do
    result = Facter::Resolvers::OsRelease.resolve(:name)

    expect(result).to eq('Ubuntu')
  end

  it 'returns os PRETTY_NAME' do
    result = Facter::Resolvers::OsRelease.resolve(:pretty_name)

    expect(result).to eq('Ubuntu 18.04.1 LTS')
  end

  it 'returns os VERSION_ID' do
    result = Facter::Resolvers::OsRelease.resolve(:version_id)

    expect(result).to eq('18.04')
  end

  it 'returns os VERSION_CODENAME' do
    result = Facter::Resolvers::OsRelease.resolve(:version_codename)

    expect(result).to eq('bionic')
  end
end
