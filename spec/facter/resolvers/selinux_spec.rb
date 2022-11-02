# frozen_string_literal: true

describe Facter::Resolvers::SELinux do
  subject(:selinux_resolver) { Facter::Resolvers::SELinux }

  let(:log_spy) { instance_spy(Facter::Log) }

  after do
    selinux_resolver.invalidate_cache
  end

  before do
    selinux_resolver.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('cat /proc/self/mounts', { logger: log_spy })
      .and_return(load_fixture(file).read)
  end

  context 'when no selinuxfs is mounted' do
    let(:file) { 'proc_self_mounts' }

    it 'returns enabled false' do
      expect(selinux_resolver.resolve(:enabled)).to be(false)
    end

    it 'returns nil for config_mode' do
      expect(selinux_resolver.resolve(:config_mode)).to be(nil)
    end
  end

  context 'when selinuxfs is mounted' do
    let(:file) { 'proc_self_mounts_selinux' }

    context 'when config file does not exist' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_readlines).with('/etc/selinux/config').and_return([])
      end

      it 'sets enabled to false' do
        expect(selinux_resolver.resolve(:enabled)).to be(false)
      end

      it 'returns nil for config_mode' do
        expect(selinux_resolver.resolve(:config_mode)).to be(nil)
      end
    end

    context 'when config file exists' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_readlines)
          .with('/etc/selinux/config').and_return(load_fixture('selinux_config').readlines)
      end

      context 'when policyvers and enforce files are readable' do
        before do
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with('/sys/fs/selinux/policyvers', nil).and_return('31')
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with('/sys/fs/selinux/enforce').and_return('1')
        end

        it 'returns enabled true' do
          expect(selinux_resolver.resolve(:enabled)).to be(true)
        end

        it 'returns config_mode enabled' do
          expect(selinux_resolver.resolve(:config_mode)).to eql('enabled')
        end

        it 'returns config_policy targeted' do
          expect(selinux_resolver.resolve(:config_policy)).to eql('targeted')
        end

        it 'returns policy_version 31' do
          expect(selinux_resolver.resolve(:policy_version)).to eql('31')
        end

        it 'returns enforced true' do
          expect(selinux_resolver.resolve(:enforced)).to be(true)
        end

        it 'returns current_mode enforcing' do
          expect(selinux_resolver.resolve(:current_mode)).to eql('enforcing')
        end
      end

      context 'when policyvers and enforce files are not readable' do
        before do
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with('/sys/fs/selinux/policyvers', nil).and_return(nil)
          allow(Facter::Util::FileHelper).to receive(:safe_read)
            .with('/sys/fs/selinux/enforce').and_return('')
        end

        it 'returns no policy_version' do
          expect(selinux_resolver.resolve(:policy_version)).to be(nil)
        end

        it 'returns enforced false' do
          expect(selinux_resolver.resolve(:enforced)).to be(false)
        end

        it 'returns current_mode enforcing on permissive' do
          expect(selinux_resolver.resolve(:current_mode)).to eql('permissive')
        end
      end
    end
  end
end
