# frozen_string_literal: true

describe 'Windows DMIComputerSystemResolver' do
  before do
    win = double('Win32Ole')
    comp = double('WIN32OLE', Name: 'VMware7,1', UUID: 'C5381A42-359D-F15B-7A62-4B6ECBA079DE')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Name,UUID FROM Win32_ComputerSystemProduct').and_return([comp])
  end

  context '#resolve' do
    it 'detects virtual machine name' do
      expect(DMIComputerSystemResolver.resolve(:name)).to eql('VMware7,1')
    end
    it 'detects uuid of virtual machine' do
      expect(DMIComputerSystemResolver.resolve(:uuid)).to eql('C5381A42-359D-F15B-7A62-4B6ECBA079DE')
    end
  end
end
