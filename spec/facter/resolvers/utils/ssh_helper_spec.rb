# frozen_string_literal: true

describe Resolvers::Utils::SshHelper do
  subject(:ssh_helper) { Resolvers::Utils::SshHelper }

  describe '#create_ssh' do
    let(:fingerprint) { instance_spy(Facter::FingerPrint) }
    let(:key) { load_fixture('rsa_key').read.strip }
    let(:ssh_object) { Facter::Ssh.new(fingerprint, 'ssh-rsa', key, 'rsa') }

    before do
      allow(Facter::FingerPrint).to receive(:new).and_return(fingerprint)
      allow(Facter::Ssh).to receive(:new).and_return(ssh_object)
    end

    it 'returns a ssh object' do
      expect(ssh_helper.create_ssh('ssh-rsa', key)).to eql(ssh_object)
    end
  end
end
