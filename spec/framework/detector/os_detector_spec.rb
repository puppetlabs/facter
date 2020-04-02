# frozen_string_literal: true

require 'rbconfig'

describe OsDetector do
  before do
    Singleton.__init__(OsDetector)
  end

  it 'detects os as macosx' do
    RbConfig::CONFIG['host_os'] = 'darwin'
    expect(OsDetector.instance.identifier).to eq(:macosx)
  end

  it 'detects os as windows' do
    RbConfig::CONFIG['host_os'] = 'mingw'
    expect(OsDetector.instance.identifier).to eq(:windows)
  end

  it 'detects os as solaris' do
    RbConfig::CONFIG['host_os'] = 'solaris'
    expect(OsDetector.instance.identifier).to eq(:solaris)
  end

  it 'detects os as aix' do
    RbConfig::CONFIG['host_os'] = 'aix'
    expect(OsDetector.instance.identifier).to eq(:aix)
  end

  it 'raise error if it could not detect os' do
    RbConfig::CONFIG['host_os'] = 'os'
    expect { OsDetector.instance.identifier }.to raise_error(RuntimeError, 'unknown os: "os"')
  end

  context 'when host_os is linux' do
    before do
      RbConfig::CONFIG['host_os'] = 'linux'

      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:identifier)
      allow(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:identifier).and_return('RedHat')

      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version)
      allow(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:version)
    end

    it 'detects linux distro' do
      expect(OsDetector.instance.detect).to eql('RedHat')
    end

    it 'calls Facter::Resolvers::OsRelease with identifier' do
      OsDetector.instance
      expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:identifier)
    end

    it 'calls Facter::Resolvers::RedHatRelease with identifier' do
      OsDetector.instance
      expect(Facter::Resolvers::RedHatRelease).to have_received(:resolve).with(:identifier)
    end

    it 'calls Facter::Resolvers::OsRelease with version' do
      OsDetector.instance
      expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version)
    end

    it 'calls Facter::Resolvers::RedHatRelease with version' do
      OsDetector.instance
      expect(Facter::Resolvers::RedHatRelease).to have_received(:resolve).with(:version)
    end
  end
end
