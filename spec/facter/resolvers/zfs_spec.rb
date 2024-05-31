# frozen_string_literal: true

describe Facter::Resolvers::ZFS do
  subject(:zfs_resolver) { Facter::Resolvers::ZFS }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('zfs upgrade -v', logger: an_instance_of(Facter::Log))
      .and_return(output)
  end

  after do
    zfs_resolver.invalidate_cache
  end

  context 'when zfs command is found' do
    let(:output) { load_fixture('zfs').read }

    it 'returns zfs version fact' do
      expect(zfs_resolver.resolve(:zfs_version)).to eq('6')
    end

    it 'returns zfs featurenumbers fact' do
      expect(zfs_resolver.resolve(:zfs_featurenumbers)).to eq('1,2,3,4,5,6')
    end
  end

  context 'when zfs command is not found' do
    let(:output) { '' }

    it 'returns nil for zfs version fact' do
      expect(zfs_resolver.resolve(:zfs_version)).to eq(nil)
    end

    it 'returns nil for zfs featurenumbers fact' do
      expect(zfs_resolver.resolve(:zfs_featurenumbers)).to eq(nil)
    end
  end
end
