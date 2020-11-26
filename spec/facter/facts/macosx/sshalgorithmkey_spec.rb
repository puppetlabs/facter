# frozen_string_literal: true

describe Facts::Macosx::Sshalgorithmkey do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Sshalgorithmkey.new }

    let(:ssh) do
      [Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
        .new('test', 'test'), 'ecdsa', 'test', 'ecdsa'),
       Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
        .new('test', 'test'), 'rsa', 'test', 'rsa')]
    end
    let(:legacy_fact1) { { name: 'ecdsa', value: 'test' } }
    let(:legacy_fact2) { { name: 'rsa', value: 'test' } }

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
        contain_exactly(an_object_having_attributes(name: "ssh#{legacy_fact1[:name]}key", value: legacy_fact1[:value]),
                        an_object_having_attributes(name: "ssh#{legacy_fact2[:name]}key", value: legacy_fact2[:value]))
    end
  end
end
