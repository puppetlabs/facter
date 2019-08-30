# frozen_string_literal: true

describe 'Windows DMIBiosResolver' do
  before do
    win = double('Win32Ole')
    comp = double('WIN32OLE', Manufacturer: 'VMware, Inc.',
                              SerialNumber: 'VMware-42 1a 38 c5 9d 35 5b f1-7a 62 4b 6e cb a0 79 de')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Manufacturer,SerialNumber from Win32_BIOS').and_return([comp])
  end

  context '#resolve' do
    it 'detects virtual machine manufacturer' do
      expect(DMIBiosResolver.resolve(:manufacturer)).to eql('VMware, Inc.')
    end
    it 'detects virtual machine serial number' do
      expect(DMIBiosResolver.resolve(:serial_number)).to eql('VMware-42 1a 38 c5 9d 35 5b f1-7a 62 4b 6e cb a0 79 de')
    end
  end
end
