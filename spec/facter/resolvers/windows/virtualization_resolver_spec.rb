# frozen_string_literal: true

describe Facter::Resolvers::Virtualization do
  let(:logger) { instance_spy(Facter::Log) }
  let(:win32ole) { instance_spy('WIN32OLE') }
  let(:win32ole2) { instance_spy('WIN32OLE') }
  let(:win) { instance_spy('Win32Ole') }

  before do
    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Manufacturer,Model,OEMStringArray FROM Win32_ComputerSystem')
                                      .and_return(query_result)
    Facter::Resolvers::Virtualization.instance_variable_set(:@log, logger)
    Facter::Resolvers::Virtualization.invalidate_cache
  end

  describe '#resolve VirtualBox' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return(vbox_version)
      allow(win32ole2).to receive(:Model).and_return(model)
      allow(win32ole2).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole2).to receive(:OEMStringArray).and_return(vbox_revision)
    end

    let(:query_result) { [win32ole, win32ole2] }
    let(:model) { 'VirtualBox' }
    let(:manufacturer) {}
    let(:vbox_version) { 'vboxVer_6.0.4' }
    let(:vbox_revision) { 'vboxRev_128413' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('virtualbox')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end

    it 'detects oem_strings facts' do
      expect(Facter::Resolvers::Virtualization.resolve(:oem_strings)).to eql([vbox_version, vbox_revision])
    end
  end

  describe '#resolve Vmware' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { 'VMware' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('vmware')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end
  end

  describe '#resolve KVM' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { 'KVM10' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('kvm')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end
  end

  describe '#resolve Openstack VM' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { 'OpenStack' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('openstack')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end
  end

  describe '#resolve Microsoft VM' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { 'Virtual Machine' }
    let(:manufacturer) { 'Microsoft' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('hyperv')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end
  end

  describe '#resolve Xen VM' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { '' }
    let(:manufacturer) { 'Xen' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('xen')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end
  end

  describe '#resolve Amazon EC2 VM' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { '' }
    let(:manufacturer) { 'Amazon EC2' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('kvm')
    end

    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(true)
    end
  end

  describe '#resolve Physical Machine' do
    before do
      allow(win32ole).to receive(:Model).and_return(model)
      allow(win32ole).to receive(:Manufacturer).and_return(manufacturer)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }
    let(:model) { '' }
    let(:manufacturer) { '' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('physical')
    end

    it 'detects that is not virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(false)
    end
  end

  describe '#resolve should cache facts in the same run' do
    let(:query_result) { nil }

    it 'detects virtual machine model' do
      Facter::Resolvers::Virtualization.instance_variable_set(:@fact_list, { virtual: 'physical' })

      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('physical')
    end

    it 'detects that is virtual' do
      Facter::Resolvers::Virtualization.instance_variable_set(:@fact_list, { is_virtual: false })

      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(false)
    end
  end

  describe '#resolve  when WMI query returns nil' do
    let(:query_result) { nil }

    it 'logs that query failed and virtual nil' do
      allow(logger).to receive(:debug)
        .with('WMI query returned no results'\
                                      ' for Win32_ComputerSystem with values Manufacturer, Model and OEMStringArray.')
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to be(nil)
    end

    it 'detects that is_virtual nil' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(nil)
    end
  end

  describe '#resolve when WMI query returns nil for Model and Manufacturer' do
    before do
      allow(win32ole).to receive(:Model).and_return(nil)
      allow(win32ole).to receive(:Manufacturer).and_return(nil)
      allow(win32ole).to receive(:OEMStringArray).and_return('')
    end

    let(:query_result) { [win32ole] }

    it 'detects that is physical' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('physical')
    end

    it 'detects that is_virtual is false' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to be(false)
    end
  end
end
