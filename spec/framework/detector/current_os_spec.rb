# frozen_string_literal: true

require 'rbconfig'

describe 'CurrentOs' do
  before do
    Singleton.__init__(CurrentOs)
  end

  it 'reads os from rbconfig' do
    RbConfig::CONFIG['host_os'] = 'darwin'
    expect(CurrentOs.instance.identifier).to eq(:macosx)
  end

  it 'detects linux distro when host_os is linux' do
    RbConfig::CONFIG['host_os'] = 'linux'

    expect(OsReleaseResolver).to receive(:resolve).with(:identifier)
    expect(RedHatReleaseResolver).to receive(:resolve).with(:identifier)
    expect(SuseReleaseResolver).to receive(:resolve).with(:identifier)

    expect(OsReleaseResolver).to receive(:resolve).with(:version)
    expect(RedHatReleaseResolver).to receive(:resolve).with(:version)
    expect(SuseReleaseResolver).to receive(:resolve).with(:version)
    CurrentOs.instance
  end
end
