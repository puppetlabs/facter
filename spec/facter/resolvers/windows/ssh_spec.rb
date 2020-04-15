# frozen_string_literal: true

describe Facter::Resolvers::Windows::Ssh do
  describe '#resolve' do
    before do
      allow(ENV).to receive(:[]).with('programdata').and_return(programdata_dir)
      allow(File).to receive(:directory?).with("#{programdata_dir}/ssh").and_return(dir_exists)
    end

    after do
      Facter::Resolvers::Windows::Ssh.invalidate_cache
    end

    context 'when programdata enviroment variable is set' do
      let(:programdata_dir) { 'C:/ProgramData' }
      let(:dir_exists) { true }

      before do
        allow(Facter::Util::FileHelper).to receive(:safe_read).with("#{programdata_dir}/ssh/ssh_host_ecdsa_key.pub")
                                                              .and_return(ecdsa_content)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with("#{programdata_dir}/ssh/ssh_host_ed25519_key.pub")
                                                              .and_return(ed25519_content)
        allow(Facter::Util::FileHelper).to receive(:safe_read).with("#{programdata_dir}/ssh/ssh_host_dsa_key.pub")
                                                              .and_return('')
        allow(Facter::Util::FileHelper).to receive(:safe_read).with("#{programdata_dir}/ssh/ssh_host_rsa_key.pub")
                                                              .and_return(rsa_content)
      end

      context 'when ecdsa, ed25519 and rsa files exists' do
        before do
          allow(Resolvers::Utils::SshHelper).to receive(:create_ssh)
            .with('ssh-rsa', load_fixture('rsa_key').read.strip!)
            .and_return(rsa_result)
          allow(Resolvers::Utils::SshHelper).to receive(:create_ssh)
            .with('ecdsa-sha2-nistp256', load_fixture('ecdsa_key').read.strip!)
            .and_return(ecdsa_result)
          allow(Resolvers::Utils::SshHelper).to receive(:create_ssh)
            .with('ssh-ed25519', load_fixture('ed25519_key').read.strip!)
            .and_return(ed25519_result)
        end

        let(:ecdsa_exists) { true }
        let(:rsa_exists) { true }
        let(:ed25519_exists) { true }
        let(:ecdsa_content) { load_fixture('ecdsa').read.strip! }
        let(:rsa_content) { load_fixture('rsa').read.strip! }
        let(:ed25519_content) { load_fixture('ed25519').read.strip! }

        let(:ecdsa_fingerprint) do
          Facter::FingerPrint.new('SSHFP 3 1 fd92cf867fac0042d491eb1067e4f3cabf54039a',
                                  'SSHFP 3 2 a51271a67987d7bbd685fa6d7cdd2823a30373ab01420b094480523fabff2a05')
        end

        let(:rsa_fingerprint) do
          Facter::FingerPrint.new('SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07',
                                  'SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99')
        end

        let(:ed25519_fingerprint) do
          Facter::FingerPrint.new('SSHFP 4 1 f5780634d4e34c6ef2411ac439b517bfdce43cf1',
                                  'SSHFP 4 2 c1257b3865df22f3349f9ebe19961c8a8edf5fbbe883113e728671b42d2c9723')
        end

        let(:ecdsa_result) do
          Facter::Ssh.new(ecdsa_fingerprint, 'ecdsa-sha2-nistp256', ecdsa_content, 'ecdsa')
        end

        let(:rsa_result) do
          Facter::Ssh.new(rsa_fingerprint, 'ssh-rsa', rsa_content, 'rsa')
        end

        let(:ed25519_result) do
          Facter::Ssh.new(ed25519_fingerprint, 'ssh-ed22519', ed25519_content, 'ed25519')
        end

        it 'returns ssh fact' do
          expect(Facter::Resolvers::Windows::Ssh.resolve(:ssh)).to eq([rsa_result, ecdsa_result, ed25519_result])
        end
      end

      context 'when files are not readable' do
        let(:ecdsa_content) { '' }
        let(:rsa_content) { '' }
        let(:ed25519_content) { '' }

        it 'returns nil' do
          expect(Facter::Resolvers::Windows::Ssh.resolve(:ssh)).to eq(nil)
        end
      end
    end

    context 'when programdata enviroment variable is not set' do
      let(:programdata_dir) { '' }
      let(:dir_exists) { false }

      it 'returns nil' do
        expect(Facter::Resolvers::Windows::Ssh.resolve(:ssh)).to eq(nil)
      end
    end
  end
end
