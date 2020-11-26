# frozen_string_literal: true

describe Facts::Windows::SshfpAlgorithm do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::SshfpAlgorithm.new }

    context 'when user is privileged' do
      let(:ssh) do
        [Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
          .new('sha11', 'sha2561'), 'ecdsa', 'test', 'ecdsa'),
         Facter::Util::Resolvers::Ssh.new(Facter::Util::Resolvers::FingerPrint
          .new('sha12', 'sha2562'), 'rsa', 'test', 'rsa')]
      end
      let(:legacy_fact1) { { name: 'ecdsa', value: "sha11\nsha2561" } }
      let(:legacy_fact2) { { name: 'rsa', value: "sha12\nsha2562" } }

      before do
        allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return(true)
        allow(Facter::Resolvers::Windows::Ssh).to receive(:resolve).with(:ssh).and_return(ssh)
      end

      it 'calls Facter::Resolvers::Windows::Identity' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Identity).to have_received(:resolve).with(:privileged)
      end

      it 'calls Facter::Resolvers::Windows::Ssh' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Ssh).to have_received(:resolve).with(:ssh)
      end

      it 'returns a list of resolved facts' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(
            an_object_having_attributes(name: "sshfp_#{legacy_fact1[:name]}", value: legacy_fact1[:value]),
            an_object_having_attributes(name: "sshfp_#{legacy_fact2[:name]}", value: legacy_fact2[:value])
          )
      end
    end

    context 'when user is privileged but no ssh key found' do
      let(:value) { nil }

      before do
        allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return(true)
        allow(Facter::Resolvers::Windows::Ssh).to receive(:resolve).with(:ssh).and_return(nil)
      end

      it 'calls Facter::Resolvers::Windows::Ssh' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Ssh).to have_received(:resolve).with(:ssh)
      end

      it 'calls Facter::Resolvers::Windows::Identity' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Identity).to have_received(:resolve).with(:privileged)
      end

      it 'returns no facts' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
      end
    end

    context 'when user is not privileged' do
      let(:value) { nil }

      before do
        allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return(false)
        allow(Facter::Resolvers::Windows::Ssh).to receive(:resolve).with(:ssh).and_return(value)
      end

      it 'calls Facter::Resolvers::Windows::Identity' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Identity).to have_received(:resolve).with(:privileged)
      end

      it "doesn't call Facter::Resolvers::Windows::Ssh" do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Ssh).not_to have_received(:resolve).with(:ssh)
      end

      it 'returns no facts' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and contain_exactly
      end
    end
  end
end
