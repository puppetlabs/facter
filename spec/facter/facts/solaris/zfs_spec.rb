# frozen_string_literal: true

describe 'Solaris ZFS' do
  context '#call_the_resolver' do
    it 'returns zfs_version fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'zfs_version', value: '6')
      allow(Facter::Resolvers::Solaris::ZFS).to receive(:resolve).with(:zfs_version).and_return('6')
      allow(Facter::ResolvedFact).to receive(:new).with('zfs_version', '6').and_return(expected_fact)

      fact = Facter::Solaris::ZFSVersion.new

      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'returns zfs_featurenumbers fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'zfs_featurenumbers', value: '1, 2, 3, 4, 5')
      allow(Facter::Resolvers::Solaris::ZFS).to receive(:resolve).with(:zfs_featurenumbers).and_return('1, 2, 3, 4, 5')
      allow(Facter::ResolvedFact).to receive(:new).with('zfs_featurenumbers', '1, 2, 3, 4, 5').and_return(expected_fact)

      fact = Facter::Solaris::ZFSFeatureNumbers.new

      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
