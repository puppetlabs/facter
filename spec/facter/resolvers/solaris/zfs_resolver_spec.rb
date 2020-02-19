# frozen_string_literal: true

describe 'SolarisZFS' do
  before do
    status = double(Process::Status, to_s: st)
    expect(Open3).to receive(:capture2)
      .with('zfs upgrade -v')
      .ordered
      .and_return([output, status])
  end

  after do
    Facter::Resolvers::Solaris::ZFS.invalidate_cache
  end
  let(:st) { 'exit 0' }

  context 'Resolve zfs facts' do
    let(:output) { load_fixture('zfs').read }
    it 'returns zfs version fact' do
      result = Facter::Resolvers::Solaris::ZFS.resolve(:zfs_version)
      expect(result).to eq('6')
    end

    it 'returns zfs featurenumbers fact' do
      result = Facter::Resolvers::Solaris::ZFS.resolve(:zfs_featurenumbers)
      expect(result).to eq('1, 2, 3, 4, 5, 6')
    end
  end

  context 'Resolve zfs facts when zfs command is not found' do
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
