# frozen_string_literal: true

describe 'OsReleaseResolver' do
  before do
    allow(Open3).to receive(:capture2)
      .with('cat /etc/os-release')
      .and_return('NAME="Ubuntu"
VERSION="18.04.1 LTS (Bionic Beaver)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 18.04.1 LTS"
VERSION_ID="18.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=bionic
UBUNTU_CODENAME=bionic')
  end

  it 'returns os NAME' do
    result = OsReleaseResolver.resolve('NAME')

    expect(result).to eq('Ubuntu')
  end

  it 'returns os PRETTY_NAME' do
    result = OsReleaseResolver.resolve('PRETTY_NAME')

    expect(result).to eq('Ubuntu 18.04.1 LTS')
  end

  it 'returns os VERSION_ID' do
    result = OsReleaseResolver.resolve('VERSION_ID')

    expect(result).to eq('18.04')
  end

  it 'returns os VERSION_CODENAME' do
    result = OsReleaseResolver.resolve('VERSION_CODENAME')

    expect(result).to eq('bionic')
  end
end
