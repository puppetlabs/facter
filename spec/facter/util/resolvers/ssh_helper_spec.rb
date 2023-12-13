# frozen_string_literal: true

describe Facter::Util::Resolvers::SshHelper do
  subject(:ssh_helper) { Facter::Util::Resolvers::SshHelper }

  describe '#create_ssh' do
    let(:key) { load_fixture('rsa_key').read.strip }

    it 'returns an RSA ssh object' do
      expect(ssh_helper.create_ssh('ssh-rsa', key)).to \
        be_an_instance_of(Facter::Util::Resolvers::Ssh).and \
          have_attributes(name: 'rsa', type: 'ssh-rsa')
    end

    it 'returns sha1 fingerprint' do
      expect(ssh_helper.create_ssh('ssh-rsa', key).fingerprint.sha1).to \
        eq('SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07')
    end

    it 'returns sha256 fingerprint' do
      expect(ssh_helper.create_ssh('ssh-rsa', key).fingerprint.sha256).to \
        eq('SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99')
    end

    it 'ignores non-base64 characters' do
      nonbase64_key = "\x00\n-_#{key}"
      expect(ssh_helper.create_ssh('ssh-rsa', nonbase64_key).fingerprint.sha1).to \
        eq('SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07')
    end

    it 'implements value semantics' do
      expect(ssh_helper.create_ssh('ssh-rsa', key)).to eq(ssh_helper.create_ssh('ssh-rsa', key))
    end
  end
end
