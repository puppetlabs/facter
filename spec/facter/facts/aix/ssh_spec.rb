# frozen_string_literal: true

describe Facter::Aix::Ssh do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      ssh1 = Facter::Ssh.new(Facter::FingerPrint.new('test', 'test'), 'ecdsa', 'test', 'ecdsa')
      ssh2 = Facter::Ssh.new(Facter::FingerPrint.new('test2', 'test2'), 'rsa', 'test2', 'rsa')
      result = [ssh1, ssh2]
      result_fact = { ssh1.name.to_sym =>
                          { fingerprints:
                                { sha1: ssh1.fingerprint.sha1,
                                  sha256: ssh1.fingerprint.sha256 },
                            key: ssh1.key,
                            type: ssh1.type },
                      ssh2.name.to_sym =>
                         { fingerprints:
                               { sha1: ssh2.fingerprint.sha1,
                                 sha256: ssh2.fingerprint.sha256 },
                           key: ssh2.key,
                           type: ssh2.type } }
      expected_fact = double(Facter::ResolvedFact, name: 'ssh', value: result_fact)
      allow(Facter::Resolvers::SshResolver).to receive(:resolve).with(:ssh).and_return(result)
      allow(Facter::ResolvedFact).to receive(:new).with('ssh', result_fact).and_return(expected_fact)

      fact = Facter::Aix::Ssh.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
