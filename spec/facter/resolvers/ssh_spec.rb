# frozen_string_literal: true

describe Facter::Resolvers::Ssh do
  describe '#folders' do
    let(:paths) { %w[/etc/ssh /usr/local/etc/ssh /etc /usr/local/etc /etc/opt/ssh] }
    let(:file_names) { %w[ssh_host_rsa_key.pub ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub] }

    before do
      paths.each { |path| allow(File).to receive(:directory?).with(path).and_return(false) unless path == '/etc' }
      allow(File).to receive(:directory?).with('/etc').and_return(true)

      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with(a_string_starting_with('/etc/ssh_host'), nil).and_return(nil)
    end

    after do
      Facter::Resolvers::Ssh.invalidate_cache
    end

    shared_examples 'an ssh key' do
      it 'resolves the key' do
        allow(Facter::Util::FileHelper).to receive(:safe_read)
          .with(path, nil).and_return(content)

        expect(Facter::Resolvers::Ssh.resolve(:ssh)).to eq([result])
      end
    end

    context 'when rsa' do
      let(:path) { '/etc/ssh_host_rsa_key.pub' }
      let(:content) { load_fixture('rsa').read }
      let(:result) do
        fingerprint = Facter::Util::Resolvers::FingerPrint.new(
          'SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07',
          'SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99'
        )
        Facter::Util::Resolvers::Ssh.new(fingerprint, *content.strip.split(' '), 'rsa')
      end

      include_examples 'an ssh key'
    end

    context 'when ecdsa' do
      let(:path) { '/etc/ssh_host_dsa_key.pub' }
      let(:content) { load_fixture('ecdsa').read }
      let(:result) do
        fingerprint = Facter::Util::Resolvers::FingerPrint.new(
          'SSHFP 3 1 fd92cf867fac0042d491eb1067e4f3cabf54039a',
          'SSHFP 3 2 a51271a67987d7bbd685fa6d7cdd2823a30373ab01420b094480523fabff2a05'
        )
        Facter::Util::Resolvers::Ssh.new(fingerprint, *content.strip.split(' '), 'ecdsa')
      end

      include_examples 'an ssh key'
    end

    context 'when ed25519' do
      let(:path) { '/etc/ssh_host_ed25519_key.pub' }
      let(:content) { load_fixture('ed25519').read }
      let(:result) do
        fingerprint = Facter::Util::Resolvers::FingerPrint.new(
          'SSHFP 4 1 1c02084d251368b98a3af97820d9fbf2b8dc9558',
          'SSHFP 4 2 656bd7aa3f8ad4703bd581888231f822cb8cd4a2a258584469551d2c2c9f6b62'
        )
        Facter::Util::Resolvers::Ssh.new(fingerprint, *content.strip.split(' '), 'ed25519')
      end

      include_examples 'an ssh key'
    end

    context 'when ecdsa 384-bit' do
      let(:path) { '/etc/ssh_host_ecdsa_key.pub' }
      let(:content) { load_fixture('ecdsa384').read }
      let(:result) do
        fingerprint = Facter::Util::Resolvers::FingerPrint.new(
          'SSHFP 3 1 a3c1dc40a07cd76ea2ffe3f57e96aae146427174',
          'SSHFP 3 2 949d92d65c6bb3908727bef5cdafef5b546650d64a081a4f85e7dcaf6b7cb7ab'
        )
        Facter::Util::Resolvers::Ssh.new(fingerprint, *content.strip.split(' '), 'ecdsa')
      end

      include_examples 'an ssh key'
    end

    context 'when ecdsa 521-bit' do
      let(:path) { '/etc/ssh_host_ecdsa_key.pub' }
      let(:content) { load_fixture('ecdsa521').read }
      let(:result) do
        fingerprint = Facter::Util::Resolvers::FingerPrint.new(
          'SSHFP 3 1 61046cb5f7b38df21fe4511a9280436ce89514ee',
          'SSHFP 3 2 b74da480da3411a79abf37d0bcfbbcaa8c1dbfc6a983365276b3c7f0c7a8de3e'
        )
        Facter::Util::Resolvers::Ssh.new(fingerprint, *content.strip.split(' '), 'ecdsa')
      end

      include_examples 'an ssh key'
    end

    context 'when no files are readable' do
      it 'returns an empty array' do
        expect(Facter::Resolvers::Ssh.resolve(:ssh)).to eq([])
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
        .with(a_string_starting_with('/etc/ssh_host'), nil)
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
