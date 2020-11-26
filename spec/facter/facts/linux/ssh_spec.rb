# frozen_string_literal: true

describe Facts::Linux::Ssh do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Ssh.new }

    let(:ssh) do
      [Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
        .new('test', 'test'), 'ecdsa', 'test', 'ecdsa')]
    end
    let(:value) do
      { 'ecdsa' => { 'fingerprints' =>
                         { 'sha1' => 'test', 'sha256' => 'test' },
                     'key' => 'test',
                     'type' => 'ecdsa' } }
    end

    before do
      allow(Facter::Resolvers::SshResolver).to \
        receive(:resolve).with(:ssh).and_return(ssh)
    end

    it 'calls Facter::Resolvers::SshResolver' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SshResolver).to have_received(:resolve).with(:ssh)
    end

    it 'returns ssh fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'ssh', value: value)
    end

    context 'when resolver returns empty array' do
      let(:ssh) { [] }

      it 'returns nil fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ssh', value: nil)
      end
    end
  end
end
