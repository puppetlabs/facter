# frozen_string_literal: true

require 'rbconfig'

describe 'CurrentOs' do
  before do
    Singleton.__init__(CurrentOs)
  end

  it 'detects os as macosx' do
    RbConfig::CONFIG['host_os'] = 'darwin'
    expect(CurrentOs.instance.identifier).to eq(:macosx)
  end

  it 'detects os as windows' do
    RbConfig::CONFIG['host_os'] = 'mingw'
    expect(CurrentOs.instance.identifier).to eq(:windows)
  end

  it 'detects os as solaris' do
    RbConfig::CONFIG['host_os'] = 'solaris'
    expect(CurrentOs.instance.identifier).to eq(:solaris)
  end

  it 'detects os as aix' do
    RbConfig::CONFIG['host_os'] = 'aix'
    expect(CurrentOs.instance.identifier).to eq(:aix)
  end

  it 'raise error if it could not detect os' do
    RbConfig::CONFIG['host_os'] = 'os'
    expect { CurrentOs.instance.identifier }.to raise_error(RuntimeError, 'unknown os: "os"')
  end

  it 'detects linux distro when host_os is linux' do
    RbConfig::CONFIG['host_os'] = 'linux'

    expect(Facter::Resolvers::OsRelease).to receive(:resolve).with(:identifier)
    expect(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:identifier)
    expect(Facter::Resolvers::SuseRelease).to receive(:resolve).with(:identifier)

    expect(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version)
    expect(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:version)
    expect(Facter::Resolvers::SuseRelease).to receive(:resolve).with(:version)
    CurrentOs.instance
  end
end
