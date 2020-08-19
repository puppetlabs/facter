# frozen_string_literal: true

describe Facts::Freebsd::ZpoolFeaturenumbers do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::ZpoolFeaturenumbers.new }

    let(:zpool_featurenumbers) { '1,2,3,4,5,6,7' }

    before do
      allow(Facter::Resolvers::Zpool).to \
        receive(:resolve).with(:zpool_featurenumbers).and_return(zpool_featurenumbers)
    end

    it 'calls Facter::Resolvers::ZPool' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Zpool).to have_received(:resolve).with(:zpool_featurenumbers)
    end

    it 'returns the zpool_featurenumbers fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'zpool_featurenumbers', value: zpool_featurenumbers)
    end
  end
end
