# frozen_string_literal: true

describe Facter::Resolvers::Containers do
  subject(:containers_resolver) { Facter::Resolvers::Containers }

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_read)
      .with('/proc/1/cgroup', nil)
      .and_return(cgroup_output)
    allow(Facter::Util::FileHelper).to receive(:safe_readlines)
      .with('/proc/1/environ', [], "\0", chomp: true)
      .and_return(environ_output)
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/.dockerenv').and_return(false)
  end

  after do
    containers_resolver.invalidate_cache
  end

  context 'when hypervisor is docker desktop' do
    let(:cgroup_output) { '0::/' }
    let(:environ_output) { ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'] }

    before do
      allow(File).to receive(:exist?).with('/.dockerenv').and_return(true)
    end

    it 'returns docker for vm' do
      expect(containers_resolver.resolve(:vm)).to eq('docker')
    end

    it 'returns empty hypervisor info' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(docker: {})
    end
  end

  context 'when hypervisor is docker' do
    let(:cgroup_output) { load_fixture('docker_cgroup').read }
    let(:environ_output) { ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'] }
    let(:result) { { docker: { 'id' => 'ee6e3c05422f1273c9b41a26f2b4ec64bdb4480d63a1ad9741e05cafc1651b90' } } }

    it 'return docker for vm' do
      expect(containers_resolver.resolve(:vm)).to eq('docker')
    end

    it 'return docker info for hypervisor' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(result)
    end
  end

  context 'when hypervisor is nspawn' do
    let(:cgroup_output) { load_fixture('cgroup_file').read }
    let(:environ_output) { ['PATH=/usr/local/sbin:/bin', 'container=systemd-nspawn', 'TERM=xterm-256color'] }
    let(:result) { { systemd_nspawn: { 'id' => 'ee6e3c05422f1273c9b41a26f2b4ec64bdb4480d63a1ad9741e05cafc1651b90' } } }

    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/machine-id', nil)
        .and_return("ee6e3c05422f1273c9b41a26f2b4ec64bdb4480d63a1ad9741e05cafc1651b90\n")
    end

    it 'return nspawn for vm' do
      expect(containers_resolver.resolve(:vm)).to eq('systemd_nspawn')
    end

    it 'return nspawn info for hypervisor' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(result)
    end

    it 'omits hypervisor info if it fails to read /etc/machine-id' do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/machine-id', nil)
        .and_return(nil)

      expect(containers_resolver.resolve(:hypervisor)).to eq(systemd_nspawn: {})
    end
  end

  context 'when hypervisor is lxc and it is discovered by cgroup' do
    let(:cgroup_output) { load_fixture('lxc_cgroup').read }
    let(:environ_output) { ['PATH=/usr/local/sbin:/sbin:/bin'] }
    let(:result) { { lxc: { 'name' => 'lxc_container' } } }

    it 'return lxc for vm' do
      expect(containers_resolver.resolve(:vm)).to eq('lxc')
    end

    it 'return lxc info for hypervisor' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(result)
    end
  end

  context 'when hypervisor is lxc and it is discovered by environ' do
    let(:cgroup_output) { load_fixture('cgroup_file').read }
    let(:environ_output) { ['container=lxc'] }
    let(:result) { { lxc: {} } }

    it 'return lxc for vm' do
      expect(containers_resolver.resolve(:vm)).to eq('lxc')
    end

    it 'return lxc info for hypervisor' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(result)
    end
  end

  context 'when hypervisor is lxc-virtwhat and it is discovered by environ' do
    let(:cgroup_output) { load_fixture('cgroup_file').read }
    let(:environ_output) { ['container=lxc-virtwhat'] }
    let(:result) { { 'lxc-virtwhat': {} } }

    it 'return lxc-virtwhat for vm' do
      expect(containers_resolver.resolve(:vm)).to eq('lxc-virtwhat')
    end

    it 'return lxc-virtwhat info for hypervisor' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(result)
    end
  end

  context 'when hypervisor is illumos' do
    let(:cgroup_output) { nil }
    let(:environ_output) { ['container=zone'] }

    it 'return nil' do
      expect(containers_resolver.resolve(:vm)).to eq(nil)
      expect(containers_resolver.resolve(:hypervisor)).to eq(nil)
    end
  end

  context 'when hypervisor is neighter lxc nor docker' do
    let(:cgroup_output) { load_fixture('cgroup_file').read }
    let(:environ_output) { ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin'] }
    let(:result) { nil }

    it 'return lxc for vm' do
      expect(containers_resolver.resolve(:vm)).to eq(nil)
    end

    it 'return lxc info for hypervisor' do
      expect(containers_resolver.resolve(:hypervisor)).to eq(result)
    end
  end

  context 'when hypervisor is an unknown container runtime discovered by environ' do
    let(:cgroup_output) { load_fixture('cgroup_file').read }
    let(:environ_output) { ['container=UNKNOWN'] }
    let(:logger) { Facter::Log.class_variable_get(:@@logger) }

    it 'return container_other for vm' do
      expect(logger).to receive(:warn).with(/Container runtime, 'UNKNOWN', is unsupported, setting to 'container_other'/)
      expect(containers_resolver.resolve(:vm)).to eq('container_other')
    end
  end
end
