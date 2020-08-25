# frozen_string_literal: true

describe Facts::Aix::SshfpAlgorithm do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::SshfpAlgorithm.new }

    let(:ssh) do
      [Facter::Ssh.new(Facter::FingerPrint.new('sha11', 'sha2561'), 'ecdsa', 'test', 'ecdsa'),
       Facter::Ssh.new(Facter::FingerPrint.new('sha12', 'sha2562'), 'rsa', 'test', 'rsa')]
    end
    let(:legacy_fact1) { { name: 'ecdsa', value: "sha11 \n sha2561" } }
    let(:legacy_fact2) { { name: 'rsa', value: "sha12 \n sha2562" } }

    before do
      allow(Facter::Resolvers::SshResolver).to \
        receive(:resolve).with(:ssh).and_return(ssh)
    end

    it 'calls Facter::Resolvers::SshResolver' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SshResolver).to have_received(:resolve).with(:ssh)
    end

    it 'returns a list of resolved facts' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: "sshfp_#{legacy_fact1[:name]}", value: legacy_fact1[:value]),
                        an_object_having_attributes(name: "sshfp_#{legacy_fact2[:name]}", value: legacy_fact2[:value]))
    end
  end
end
