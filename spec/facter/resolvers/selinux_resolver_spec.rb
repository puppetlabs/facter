# frozen_string_literal: true

describe Facter::Resolvers::SELinux do
  after do
    Facter::Resolvers::SELinux.invalidate_cache
  end

  context 'when selinux is disabled' do
    before do
      allow(Open3).to receive(:capture2)
        .with('cat /proc/self/mounts')
        .and_return(load_fixture('proc_self_mounts').read)
    end

    it 'returns false when selinux is not enabled' do
      result = Facter::Resolvers::SELinux.resolve(:enabled)

      expect(result).to be(false)
    end

    it 'returns nil for config_mode' do
      result = Facter::Resolvers::SELinux.resolve(:config_mode)

      expect(result).to be(nil)
    end
  end

  context 'when selinux is enabled but selinux/config file does not exists' do
    before do
      allow(Open3).to receive(:capture2)
        .with('cat /proc/self/mounts')
        .and_return(load_fixture('proc_self_mounts_selinux').read)
      allow(Facter::Util::FileHelper).to receive(:safe_readlines).with('/etc/selinux/config').and_return([])
    end

    it 'returns true when selinux is enabled' do
      result = Facter::Resolvers::SELinux.resolve(:enabled)

      expect(result).to be(true)
    end

    it 'returns nil for config_mode' do
      result = Facter::Resolvers::SELinux.resolve(:config_mode)

      expect(result).to be(nil)
    end
  end

  context 'when selinux is enabled and selinux/config file exists' do
    before do
      allow(Open3).to receive(:capture2)
        .with('cat /proc/self/mounts').and_return(load_fixture('proc_self_mounts_selinux').read)
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/etc/selinux/config').and_return(load_fixture('selinux_config').readlines)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/fs/selinux/policyvers', nil).and_return('31')
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/fs/selinux/enforce').and_return('1')
    end

    it 'returns enabled true' do
      result = Facter::Resolvers::SELinux.resolve(:enabled)

      expect(result).to be(true)
    end

    it 'returns config_mode enabled' do
      result = Facter::Resolvers::SELinux.resolve(:config_mode)

      expect(result).to eql('enabled')
    end

    it 'returns config_policy targeted' do
      result = Facter::Resolvers::SELinux.resolve(:config_policy)

      expect(result).to eql('targeted')
    end

    it 'returns policy_version 31' do
      result = Facter::Resolvers::SELinux.resolve(:policy_version)

      expect(result).to eql('31')
    end

    it 'returns enforced true' do
      result = Facter::Resolvers::SELinux.resolve(:enforced)

      expect(result).to be(true)
    end

    it 'returns current_mode enforcing' do
      result = Facter::Resolvers::SELinux.resolve(:current_mode)

      expect(result).to eql('enforcing')
    end
  end

  context 'when selinux is enabled but enforce and policyvers files are not readable' do
    before do
      allow(Open3).to receive(:capture2)
        .with('cat /proc/self/mounts').and_return(load_fixture('proc_self_mounts_selinux').read)
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/etc/selinux/config').and_return(load_fixture('selinux_config').read.split("\n"))
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/fs/selinux/policyvers', nil).and_return(nil)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/sys/fs/selinux/enforce').and_return('')
    end

    it 'returns no policy_version' do
      result = Facter::Resolvers::SELinux.resolve(:policy_version)

      expect(result).to be(nil)
    end

    it 'returns enforced false' do
      result = Facter::Resolvers::SELinux.resolve(:enforced)

      expect(result).to be(false)
    end

    it 'returns current_mode enforcing on permissive' do
      result = Facter::Resolvers::SELinux.resolve(:current_mode)

      expect(result).to eql('permissive')
    end
  end
end
