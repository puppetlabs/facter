# frozen_string_literal: true

describe 'Windows WinOsReleaseResolver' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT ProductType,OtherTypeDescription FROM Win32_OperatingSystem')
                                        .and_return(comp)
    allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelmajorversion).and_return(version)
  end
  after do
    Facter::Resolvers::WinOsRelease.invalidate_cache
  end

  context '#resolve when query fails' do
    let(:comp) { nil }
    let(:version) { nil }

    it 'logs debug message and facts are nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results for Win32_OperatingSystem'\
                   'with values ProductType and OtherTypeDescription.')

      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql(nil)
    end
  end

  context '#resolve when kernel major version is nil' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { nil }
    let(:prod) {}
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql(nil)
    end
  end

  context '#resolve kernel version is 10' do
    before do
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return(full_version)
    end
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '10.0' }
    let(:prod) { '1' }
    let(:full_version) { '10.0.123' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('10')
    end
  end

  context '#resolve kernel version is 2019' do
    before do
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return(full_version)
    end
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '10.0' }
    let(:prod) { '2' }
    let(:full_version) { '10.0.17623' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('2019')
    end
  end

  context '#resolve kernel version is 2016' do
    before do
      allow(Facter::Resolvers::Kernel).to receive(:resolve).with(:kernelversion).and_return(full_version)
    end
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '10.0' }
    let(:prod) { '2' }
    let(:full_version) { '10.0.176' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('2016')
    end
  end

  context '#resolve version is 8.1' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '6.3' }
    let(:prod) { '1' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('8.1')
    end
  end

  context '#resolve version is 2012 R2' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '6.3' }
    let(:prod) { '2' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('2012 R2')
    end
  end

  context '#resolve version is XP' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '5.2' }
    let(:prod) { '1' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('XP')
    end
  end

  context '#resolve version is 2003' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '5.2' }
    let(:prod) { '2' }
    let(:type) {}

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('2003')
    end
  end

  context '#resolve version is 2003 R2' do
    let(:comp) { double('Win32Ole', ProductType: prod, OtherTypeDescription: type) }
    let(:version) { '5.2' }
    let(:prod) { '2' }
    let(:type) { 'R2' }

    it 'facts are nil' do
      expect(Facter::Resolvers::WinOsRelease.resolve(:full)).to eql('2003 R2')
    end
  end
end
