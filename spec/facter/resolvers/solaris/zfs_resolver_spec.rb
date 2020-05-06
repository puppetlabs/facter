# frozen_string_literal: true

describe Facter::Resolvers::Solaris::ZFS do
  before do
    status = double(Process::Status, to_s: st)
    allow(Open3).to receive(:capture2)
      .with('zfs upgrade -v')
      .and_return([output, status])
  end

  after do
    Facter::Resolvers::Solaris::ZFS.invalidate_cache
  end

  let(:st) { 'exit 0' }

  context 'when zfs command is found' do
    let(:output) { load_fixture('zfs').read }

    it 'returns zfs version fact' do
      result = Facter::Resolvers::Solaris::ZFS.resolve(:zfs_version)
      expect(result).to eq('6')
    end

    it 'returns zfs featurenumbers fact' do
      result = Facter::Resolvers::Solaris::ZFS.resolve(:zfs_featurenumbers)
      expect(result).to eq('1,2,3,4,5,6')
    end
  end

  context 'when zfs command is not found' do
    let(:output) { 'zfs command not found' }

    it 'returns nil for zfs version fact' do
      result = Facter::Resolvers::Solaris::ZFS.resolve(:zfs_version)
      expect(result).to eq(nil)
    end

    it 'returns nil for zfs featurenumbers fact' do
      result = Facter::Resolvers::Solaris::ZFS.resolve(:zfs_featurenumbers)
      expect(result).to eq(nil)
    end
  end
end
