# frozen_string_literal: true

describe Facts::Freebsd::Ssh do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Ssh.new }

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
      allow(Facter::Resolvers::Ssh).to \
        receive(:resolve).with(:ssh).and_return(ssh)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'ssh', value: value)
    end
  end
end
