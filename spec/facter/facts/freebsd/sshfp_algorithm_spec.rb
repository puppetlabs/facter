# frozen_string_literal: true

describe Facts::Freebsd::SshfpAlgorithm do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::SshfpAlgorithm.new }

    let(:ssh) do
      [Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
        .new('sha11', 'sha2561'), 'ecdsa', 'test', 'ecdsa'),
       Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
        .new('sha12', 'sha2562'), 'rsa', 'test', 'rsa')]
    end
    let(:legacy_fact1) { { name: 'ecdsa', value: "sha11\nsha2561" } }
    let(:legacy_fact2) { { name: 'rsa', value: "sha12\nsha2562" } }

    before do
      allow(Facter::Resolvers::Ssh).to \
        receive(:resolve).with(:ssh).and_return(ssh)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: "sshfp_#{legacy_fact1[:name]}", value: legacy_fact1[:value]),
                        an_object_having_attributes(name: "sshfp_#{legacy_fact2[:name]}", value: legacy_fact2[:value]))
    end
  end
end
