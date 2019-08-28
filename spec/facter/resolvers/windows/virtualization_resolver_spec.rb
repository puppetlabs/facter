# frozen_string_literal: true

describe 'Windows VirtualizationResolver' do
  before do
    win = double('Win32Ole')
    comp = double('WIN32OLE', Model: model, Manufacturer: manufacturer)

    allow(Win32Ole).to receive(:new).and_return(win)
    allow(win).to receive(:exec_query).with('SELECT Manufacturer,Model FROM Win32_ComputerSystem').and_return([comp])
  end

  context '#resolve VirtualBox' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'VirtualBox' }
    let(:manufacturer) {}

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('virtualbox')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Vmware' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'VMware' }
    let(:manufacturer) {}

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('vmware')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve KVM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'KVM10' }
    let(:manufacturer) {}

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('kvm')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Bochs VM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'Bochs' }
    let(:manufacturer) {}

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('bochs')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Google VM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'Google' }
    let(:manufacturer) {}

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('gce')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Openstack VM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'OpenStack' }
    let(:manufacturer) {}

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('openstack')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Microsoft VM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { 'Virtual Machine' }
    let(:manufacturer) { 'Microsoft' }

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('hyperv')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Xen VM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { '' }
    let(:manufacturer) { 'Xen' }

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('xen')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Amazon EC2 VM' do
    after do
      VirtualizationResolver.invalidate_cache
    end
    let(:model) { '' }
    let(:manufacturer) { 'Amazon EC2' }

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('kvm')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('true')
    end
  end

  context '#resolve Physical Machine' do
    let(:model) { '' }
    let(:manufacturer) { '' }

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('physical')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('false')
    end
  end

  context '#resolve should cache facts in the same run' do
    let(:model) { '' }
    let(:manufacturer) { 'Amazon EC2' }

    it 'should detect virtual machine model' do
      expect(VirtualizationResolver.resolve(:virtual)).to eql('physical')
    end
    it 'should detect that is virtual' do
      expect(VirtualizationResolver.resolve(:is_virtual)).to eql('false')
    end
  end
end
