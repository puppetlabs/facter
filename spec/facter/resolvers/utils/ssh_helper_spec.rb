# frozen_string_literal: true

describe Resolvers::Utils::SshHelper do
  subject(:ssh_helper) { Resolvers::Utils::SshHelper }

  describe '#create_ssh' do
    let(:fingerprint) { instance_spy(Facter::FingerPrint) }
    let(:key) { load_fixture('rsa_key').read.strip }

    before do
      allow(Facter::FingerPrint).to receive(:new).and_return(fingerprint)
    end

    it 'returns a ssh object' do
      expect(ssh_helper.create_ssh('ssh-rsa', key)).to be_an_instance_of(Facter::Ssh).and \
        have_attributes(name: 'rsa', type: 'ssh-rsa', fingerprint: fingerprint)
    end
  end
end
