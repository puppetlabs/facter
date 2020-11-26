# frozen_string_literal: true

describe Facts::Macosx::Ssh do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Ssh.new }

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

    it 'calls Facter::Resolvers::Ssh' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Ssh).to have_received(:resolve).with(:ssh)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'ssh', value: value)
    end

    context 'when resolver returns empty list' do
      let(:ssh) { [] }

      it 'returns a nil fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ssh', value: nil)
      end
    end
  end
end
