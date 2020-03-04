# frozen_string_literal: true

describe Facts::Solaris::ZfsFeaturenumbers do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Solaris::ZfsFeaturenumbers.new }

    let(:feature_numbers) { '1,2,3,4,5' }

    before do
      allow(Facter::Resolvers::Solaris::ZFS).to receive(:resolve).with(:zfs_featurenumbers).and_return(feature_numbers)
    end

    it 'calls Facter::Resolvers::Solaris::ZFS' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Solaris::ZFS).to have_received(:resolve).with(:zfs_featurenumbers)
    end

    it 'returns zfs_featurenumbers fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'zfs_featurenumbers', value: feature_numbers)
    end
  end
end
