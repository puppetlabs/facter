# frozen_string_literal: true

describe Facter::Resolvers::Ssh do
  describe '#folders' do
    let(:ecdsa_content) { load_fixture('ecdsa').read.strip! }
    let(:rsa_content) { load_fixture('rsa').read.strip! }
    let(:ed25519_content) { load_fixture('ed25519').read.strip! }

    let(:ecdsa_fingerprint) do
      Facter::Util::Resolvers::FingerPrint.new(
        'SSHFP 3 1 fd92cf867fac0042d491eb1067e4f3cabf54039a',
        'SSHFP 3 2 a51271a67987d7bbd685fa6d7cdd2823a30373ab01420b094480523fabff2a05'
      )
    end

    let(:rsa_fingerprint) do
      Facter::Util::Resolvers::FingerPrint.new(
        'SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07',
        'SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99'
      )
    end

    let(:ed25519_fingerprint) do
      Facter::Util::Resolvers::FingerPrint.new(
        'SSHFP 4 1 f5780634d4e34c6ef2411ac439b517bfdce43cf1',
        'SSHFP 4 2 c1257b3865df22f3349f9ebe19961c8a8edf5fbbe883113e728671b42d2c9723'
      )
    end

    let(:ecdsa_result) do
      Facter::Util::Resolvers::Ssh.new(ecdsa_fingerprint, 'ecdsa-sha2-nistp256', ecdsa_content, 'ecdsa')
    end

    let(:rsa_result) do
      Facter::Util::Resolvers::Ssh.new(rsa_fingerprint, 'ssh-rsa', rsa_content, 'rsa')
    end
    let(:ed25519_result) do
      Facter::Util::Resolvers::Ssh.new(ed25519_fingerprint, 'ssh-ed22519', ed25519_content, 'ed25519')
    end

    let(:paths) { %w[/etc/ssh /usr/local/etc/ssh /etc /usr/local/etc /etc/opt/ssh] }
    let(:file_names) { %w[ssh_host_rsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub] }

    before do
      paths.each { |path| allow(File).to receive(:directory?).with(path).and_return(false) unless path == '/etc' }
      allow(File).to receive(:directory?).with('/etc').and_return(true)

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_ecdsa_key.pub', nil).and_return(ecdsa_content)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_dsa_key.pub', nil).and_return(nil)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_rsa_key.pub', nil).and_return(rsa_content)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_ed25519_key.pub', nil).and_return(ed25519_content)

      allow(Facter::Util::Resolvers::SshHelper).to receive(:create_ssh)
        .with('ssh-rsa', load_fixture('rsa_key').read.strip!)
        .and_return(rsa_result)
      allow(Facter::Util::Resolvers::SshHelper).to receive(:create_ssh)
        .with('ecdsa-sha2-nistp256', load_fixture('ecdsa_key').read.strip!)
        .and_return(ecdsa_result)
      allow(Facter::Util::Resolvers::SshHelper).to receive(:create_ssh)
        .with('ssh-ed25519', load_fixture('ed25519_key').read.strip!)
        .and_return(ed25519_result)
    end

    after do
      Facter::Resolvers::Ssh.invalidate_cache
    end

    context 'when ssh_host_dsa_key.pub file is not readable' do
      it 'returns resolved ssh' do
        expect(Facter::Resolvers::Ssh.resolve(:ssh)).to eq([rsa_result, ecdsa_result, ed25519_result])
      end
    end

    context 'when ssh_host_ecdsa_key.pub file is also not readable' do
      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with('/etc/ssh_host_ecdsa_key.pub', nil).and_return(nil)
      end

      it 'returns resolved ssh' do
        expect(Facter::Resolvers::Ssh.resolve(:ssh)).to eq([rsa_result, ed25519_result])
      end
    end

    context 'when ssh fails to be retrieved' do
      before do
        paths.each { |path| allow(File).to receive(:directory?).with(path).and_return(false) }
      end

      it 'returns empty array' do
        expect(Facter::Resolvers::Ssh.resolve(:ssh)).to eq([])
      end
    end
  end

  describe 'invalid files' do
    let(:paths) { %w[/etc/ssh /usr/local/etc/ssh /etc /usr/local/etc /etc/opt/ssh] }
    let(:file_names) { %w[ssh_host_rsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub] }

    before do
      paths.each { |path| allow(File).to receive(:directory?).with(path).and_return(false) unless path == '/etc' }
      allow(File).to receive(:directory?).with('/etc').and_return(true)

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_ecdsa_key.pub', nil).and_return('invalid key')
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_dsa_key.pub', nil).and_return(nil)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_rsa_key.pub', nil).and_return(nil)
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/etc/ssh_host_ed25519_key.pub', nil).and_return(nil)
    end

    after do
      Facter::Resolvers::Ssh.invalidate_cache
    end

    context 'when reading invalid ssh key' do
      it 'returns empty array' do
        expect(Facter::Resolvers::Ssh.resolve(:ssh)).to eq([])
      end
    end
  end
end
