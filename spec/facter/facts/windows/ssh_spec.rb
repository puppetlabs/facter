# frozen_string_literal: true

describe Facts::Windows::Ssh do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Ssh.new }

    context 'when user is privileged' do
      let(:ssh) do
        [Facter::Ssh.new(Facter::FingerPrint.new('test', 'test'), 'ecdsa', 'test', 'ecdsa')]
      end
      let(:value) do
        { 'ecdsa' => { 'fingerprints' =>
                           { 'sha1' => 'test', 'sha256' => 'test' },
                       'key' => 'test',
                       'type' => 'ecdsa' } }
      end

      before do
        allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return(true)
        allow(Facter::Resolvers::Windows::Ssh).to receive(:resolve).with(:ssh).and_return(ssh)
      end

      it 'calls Facter::Resolvers::Windows::Ssh' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Ssh).to have_received(:resolve).with(:ssh)
      end

      it 'calls Facter::Resolvers::Windows::Identity' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Identity).to have_received(:resolve).with(:privileged)
      end

      it 'returns ssh fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ssh', value: value)
      end
    end

    context 'when user is privileged but no ssh key found' do
      let(:value) { nil }

      before do
        allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return(true)
        allow(Facter::Resolvers::Windows::Ssh).to receive(:resolve).with(:ssh).and_return({})
      end

      it 'calls Facter::Resolvers::Windows::Ssh' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Ssh).to have_received(:resolve).with(:ssh)
      end

      it 'calls Facter::Resolvers::Windows::Identity' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Identity).to have_received(:resolve).with(:privileged)
      end

      it 'returns ssh fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ssh', value: value)
      end
    end

    context 'when user is not privileged' do
      let(:value) { nil }

      before do
        allow(Facter::Resolvers::Identity).to receive(:resolve).with(:privileged).and_return(false)
        allow(Facter::Resolvers::Windows::Ssh).to receive(:resolve).with(:ssh).and_return(value)
      end

      it "doesn't call Facter::Resolvers::Windows::Ssh" do
        fact.call_the_resolver
        expect(Facter::Resolvers::Windows::Ssh).not_to have_received(:resolve).with(:ssh)
      end

      it 'calls Facter::Resolvers::Windows::Identity' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Identity).to have_received(:resolve).with(:privileged)
      end

      it 'returns ssh fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'ssh', value: value)
      end
    end
  end
end
