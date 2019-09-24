# frozen_string_literal: true

describe 'Windows VirtualizationResolver' do
  before do
    win = double('Win32Ole')

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:return_first).with('SELECT Manufacturer,Model FROM Win32_ComputerSystem').and_return(comp)
  end

  context '#resolve VirtualBox' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { 'VirtualBox' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('virtualbox')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Vmware' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { 'VMware' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('vmware')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve KVM' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { 'KVM10' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('kvm')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Openstack VM' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { 'OpenStack' }
    let(:manufacturer) {}

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('openstack')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Microsoft VM' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { 'Virtual Machine' }
    let(:manufacturer) { 'Microsoft' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('hyperv')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Xen VM' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { '' }
    let(:manufacturer) { 'Xen' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('xen')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Amazon EC2 VM' do
    after do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { '' }
    let(:manufacturer) { 'Amazon EC2' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('kvm')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Physical Machine' do
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { '' }
    let(:manufacturer) { '' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('physical')
    end
    it 'detects that is not virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('false')
    end
  end

  context '#resolve should cache facts in the same run' do
    let(:comp) { double('WIN32OLE', Model: model, Manufacturer: manufacturer) }
    let(:model) { '' }
    let(:manufacturer) { 'Amazon EC2' }

    it 'detects virtual machine model' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('physical')
    end
    it 'detects that is virtual' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('false')
    end
  end

  context '#resolve  when WMI query returns nil' do
    before do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { nil }

    it 'logs that query failed and virtual nil' do
      allow_any_instance_of(Facter::Log).to receive(:debug)
        .with('WMI query returned no results'\
                                                ' for Win32_ComputerSystem with values Manufacturer and Model.')
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql(nil)
    end
    it 'detects that is_virtual nil' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql(nil)
    end
  end

  context '#resolve when WMI query returns nil for Model and Manufacturer' do
    before do
      Facter::Resolvers::Virtualization.invalidate_cache
    end
    let(:comp) { double('WIN32OLE', Model: nil, Manufacturer: nil) }

    it 'detects that is physical' do
      expect(Facter::Resolvers::Virtualization.resolve(:virtual)).to eql('physical')
    end
    it 'detects that is_virtual is false' do
      expect(Facter::Resolvers::Virtualization.resolve(:is_virtual)).to eql('false')
    end
  end
end
