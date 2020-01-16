# frozen_string_literal: true

describe 'Fedora Ssh' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      result = []
      ssh = Facter::Ssh.new(Facter::FingerPrint.new('test', 'test'), 'ecdsa', 'test', 'ecdsa')
      result << ssh
      result_fact = { ssh.name.to_sym =>
                          { fingerprints: { sha1: ssh.fingerprint.sha1,
                                            sha256: ssh.fingerprint.sha256 },
                            key: ssh.key,
                            type: ssh.type } }
      expected_fact = double(Facter::ResolvedFact, name: 'ssh', value: result_fact)
      allow(Facter::Resolvers::SshResolver).to receive(:resolve).with(:ssh).and_return(result)
      allow(Facter::ResolvedFact).to receive(:new).with('ssh', result_fact).and_return(expected_fact)

      fact = Facter::El::Ssh.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
