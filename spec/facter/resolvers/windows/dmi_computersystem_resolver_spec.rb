# frozen_string_literal: true

describe Facter::Resolvers::DMIComputerSystem do
  let(:logger) { instance_spy(Facter::Log) }

  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT Name,UUID FROM Win32_ComputerSystemProduct').and_return(comp)

    Facter::Resolvers::DMIComputerSystem.instance_variable_set(:@log, logger)
  end

  after do
    Facter::Resolvers::DMIComputerSystem.invalidate_cache
  end

  describe '#resolve' do
    let(:comp) { double('WIN32OLE', Name: 'VMware7,1', UUID: 'C5381A42-359D-F15B-7A62-4B6ECBA079DE') }

    it 'detects virtual machine name' do
      expect(Facter::Resolvers::DMIComputerSystem.resolve(:name)).to eql('VMware7,1')
    end

    it 'detects uuid of virtual machine' do
      expect(Facter::Resolvers::DMIComputerSystem.resolve(:uuid)).to eql('C5381A42-359D-F15B-7A62-4B6ECBA079DE')
    end
  end

  describe '#resolve when WMI query returns nil' do
    let(:comp) {}

    it 'logs debug message and name is nil' do
      allow(logger).to receive(:debug)
        .with('WMI query returned no results for Win32_ComputerSystemProduct with values Name and UUID.')
      expect(Facter::Resolvers::DMIComputerSystem.resolve(:name)).to be(nil)
    end

    it 'detects uuid as nil' do
      expect(Facter::Resolvers::DMIComputerSystem.resolve(:uuid)).to be(nil)
    end
  end

  describe '#resolve when WMI query returns nil for Name and UUID' do
    let(:comp) { double('WIN32OLE', Name: nil, UUID: nil) }

    it 'detects name as nil' do
      expect(Facter::Resolvers::DMIComputerSystem.resolve(:name)).to be(nil)
    end

    it 'detects uuid as nil' do
      expect(Facter::Resolvers::DMIComputerSystem.resolve(:uuid)).to be(nil)
    end
  end
end
