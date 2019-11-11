# frozen_string_literal: true

describe 'Sles Ssh' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      result = []
      ssh = Facter::Ssh.new(Facter::FingerPrint.new('test', 'test'), 'ecdsa', 'test', 'ecdsa')
      result << ssh
      result_fact = { ssh.name.to_sym =>
                               { 'fingerprints'.to_sym =>
                                     { 'sha1'.to_sym => ssh.fingerprint.sha1,
                                       'sha256'.to_sym => ssh.fingerprint.sha256 },
                                 'key'.to_sym => ssh.key,
                                 'type'.to_sym => ssh.type } }
      expected_fact = double(Facter::ResolvedFact, name: 'ssh', value: result_fact)
      allow(Facter::Resolvers::SshResolver).to receive(:resolve).with(:ssh).and_return(result)
      allow(Facter::ResolvedFact).to receive(:new).with('ssh', result_fact).and_return(expected_fact)

      fact = Facter::Sles::Ssh.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
