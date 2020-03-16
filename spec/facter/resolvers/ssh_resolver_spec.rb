# frozen_string_literal: true

describe Facter::Resolvers::SshResolver do
  describe '#folders' do
    let(:paths) { %w[/etc/ssh /usr/local/etc/ssh /etc /usr/local/etc /etc/opt/ssh] }
    let(:file_names) { %w[ssh_host_rsa_key.pub ssh_host_dsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub] }

    before do
      paths.each { |path| allow(File).to receive(:directory?).with(path).and_return(false) unless path == '/etc' }
      allow(File).to receive(:directory?).with('/etc').and_return(true)

      file_names.each do |file_name|
        unless file_name == 'ssh_host_rsa_key.pub'
          allow(FileTest).to receive(:file?).with('/etc/' + file_name)
                                            .and_return(false)
        end
      end

      allow(FileTest).to receive(:file?).with('/etc/ssh_host_ecdsa_key.pub').and_return(true)
      allow(FileTest).to receive(:file?).with('/etc/ssh_host_rsa_key.pub').and_return(true)
      allow(FileTest).to receive(:file?).with('/etc/ssh_host_ed25519_key.pub').and_return(true)
      expect(File).to receive(:read).with('/etc/ssh_host_ecdsa_key.pub').and_return(ecdsa_content)
      expect(File).to receive(:read).with('/etc/ssh_host_rsa_key.pub').and_return(rsa_content)
      expect(File).to receive(:read).with('/etc/ssh_host_ed25519_key.pub').and_return(ed25519_content)

      expect(Facter::FingerPrint)
        .to receive(:new)
        .with('SSHFP 3 1 fd92cf867fac0042d491eb1067e4f3cabf54039a',
              'SSHFP 3 2 a51271a67987d7bbd685fa6d7cdd2823a30373ab01420b094480523fabff2a05')
        .and_return(ecdsa_fingerprint)

      expect(Facter::FingerPrint)
        .to receive(:new)
        .with('SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07',
              'SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99')
        .and_return(rsa_fingerprint)

      expect(Facter::FingerPrint)
        .to receive(:new)
        .with('SSHFP 4 1 1c02084d251368b98a3af97820d9fbf2b8dc9558',
              'SSHFP 4 2 656bd7aa3f8ad4703bd581888231f822cb8cd4a2a258584469551d2c2c9f6b62')
        .and_return(ed25519_fingerprint)

      expect(Facter::Ssh)
        .to receive(:new).with(ecdsa_fingerprint, 'ecdsa-sha2-nistp256', load_fixture('ecdsa_key').read.strip!,
                               'ecdsa')
                         .and_return(ecdsa_result)

      expect(Facter::Ssh)
        .to receive(:new).with(rsa_fingerprint, 'ssh-rsa', load_fixture('rsa_key').read.strip!, 'rsa')
                         .and_return(rsa_result)

      expect(Facter::Ssh)
        .to receive(:new).with(ed25519_fingerprint, 'ssh-ed25519', load_fixture('ed25519_key').read.strip!, 'ed25519')
                         .and_return(ed25519_result)
    end

    after do
      Facter::Resolvers::SshResolver.invalidate_cache
    end

    context 'ecdsa file exists' do
      let(:ecdsa_content) { load_fixture('ecdsa').read.strip! }
      let(:rsa_content) { load_fixture('rsa').read.strip! }
      let(:ed25519_content) { load_fixture('ed25519').read.strip! }

      let(:ecdsa_fingerprint) do
        double(Facter::FingerPrint,
               sha1: 'SSHFP 3 1 fd92cf867fac0042d491eb1067e4f3cabf54039a',
               sha256: 'SSHFP 3 2 a51271a67987d7bbd685fa6d7cdd2823a30373ab01420b094480523fabff2a05')
      end

      let(:rsa_fingerprint) do
        double(Facter::FingerPrint,
               sha1: 'SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07',
               sha256: 'SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99')
      end

      let(:ed25519_fingerprint) do
        double(Facter::FingerPrint,
               sha1: 'SSHFP 4 1 f5780634d4e34c6ef2411ac439b517bfdce43cf1',
               sha256: 'SSHFP 4 2 c1257b3865df22f3349f9ebe19961c8a8edf5fbbe883113e728671b42d2c9723')
      end

      let(:ecdsa_result) do
        double(Facter::Ssh, fingerprint: ecdsa_fingerprint, type: 'ecdsa-sha2-nistp256',
                            key: load_fixture('ecdsa_key').read.strip!, name: 'ecdsa')
      end

      let(:rsa_result) do
        double(Facter::Ssh, fingerprint: rsa_fingerprint, type: 'ssh-rsa',
                            key: load_fixture('rsa_key').read.strip!, name: 'rsa')
      end

      let(:ed25519_result) do
        double(Facter::Ssh, fingerpint: ed25519_fingerprint, type: 'ssh-ed22519',
                            key: load_fixture('ed25519_key').read.strip!, name: 'ed25519')
      end

      it 'returns fact' do
        expect(Facter::Resolvers::SshResolver.resolve(:ssh)).to eq([rsa_result, ecdsa_result, ed25519_result])
      end
    end
  end
end
