# frozen_string_literal: true

describe 'Windows DMIBiosResolver' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT Manufacturer,SerialNumber from Win32_BIOS').and_return(comp)
  end
  after do
    Facter::Resolvers::DMIBiosResolver.invalidate_cache
  end

  context '#resolve' do
    let(:comp) do
      double('WIN32OLE', Manufacturer: 'VMware, Inc.',
                         SerialNumber: 'VMware-42 1a 38 c5 9d 35 5b f1-7a 62 4b 6e cb a0 79 de')
    end

    it 'detects virtual machine manufacturer' do
      expect(Facter::Resolvers::DMIBiosResolver.resolve(:manufacturer)).to eql('VMware, Inc.')
    end
    it 'detects virtual machine serial number' do
      expect(Facter::Resolvers::DMIBiosResolver.resolve(:serial_number))
        .to eql('VMware-42 1a 38 c5 9d 35 5b f1-7a 62 4b 6e cb a0 79 de')
    end
  end

  context '#resolve when WMI query returns nil' do
    let(:comp) {}

    it 'logs debug message and serial_number is nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results for Win32_BIOS with values Manufacturer and SerialNumber.')
      expect(Facter::Resolvers::DMIBiosResolver.resolve(:serial_number)).to eql(nil)
    end
    it 'detects manufacturer as nil' do
      expect(Facter::Resolvers::DMIBiosResolver.resolve(:manufacturer)).to eql(nil)
    end
  end

  context '#resolve when WMI query returns nil for Manufacturer and SerialNumber' do
    let(:comp) do
      double('WIN32OLE', Manufacturer: nil,
                         SerialNumber: nil)
    end

    it 'detects SerialNumber as nil' do
      expect(Facter::Resolvers::DMIBiosResolver.resolve(:serial_number)).to eql(nil)
    end
    it 'detects manufacturer as nil' do
      expect(Facter::Resolvers::DMIBiosResolver.resolve(:manufacturer)).to eql(nil)
    end
  end
end
