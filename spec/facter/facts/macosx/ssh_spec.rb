# frozen_string_literal: true

describe Facts::Macosx::Ssh do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Ssh.new }

    let(:ssh) do
      [Facter::Ssh.new(Facter::FingerPrint.new('sha1_value', 'sha256_value'), 'ecdsa', 'key_value', 'ecdsa')]
    end
    let(:value) do
      { 'ecdsa' => { 'fingerprints' =>
                       { 'sha1' => 'sha1_value', 'sha256' => 'sha256_value' },
                     'key' => 'key_value',
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

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Array)
        .and contain_exactly(
          an_object_having_attributes(name: 'ssh', value: value),
          an_object_having_attributes(name: 'sshecdsakey', value: 'key_value'),
          an_object_having_attributes(name: 'sshfp_ecdsa', value: "sha1_value\nsha256_value")
        )
    end

    context 'when resolver returns empty list' do
      let(:ssh) { [] }

      it 'returns nil fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array)
          .and contain_exactly(
            an_object_having_attributes(name: 'ssh', value: nil)
          )
      end
    end
  end
end
