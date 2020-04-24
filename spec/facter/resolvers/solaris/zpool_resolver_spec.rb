# frozen_string_literal: true

describe Facter::Resolvers::Solaris::ZPool do
  before do
    status = double(Process::Status, to_s: st)
    allow(Open3).to receive(:capture2)
      .with('zpool upgrade -v')
      .ordered
      .and_return([output, status])
  end

  after do
    Facter::Resolvers::Solaris::ZPool.invalidate_cache
  end

  let(:st) { 'exit 0' }

  context 'when zpool command is found' do
    let(:output) { load_fixture('zpool').read }

    it 'return zpool version fact' do
      result = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_version)
      expect(result).to eq('34')
    end

    it 'return zpool featurenumbers fact' do
      result = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_featurenumbers)
      expect(result).to eq('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,' \
        '24,25,26,27,28,29,30,31,32,33,34')
    end

    context 'when zpool has featureflags' do
      let(:output) { load_fixture('zpool-with-featureflags').read }
      let(:zpool_featureflags) do
        'async_destroy,empty_bpobj,lz4_compress,multi_vdev_crash_dump,spacemap_histogram,enabled_txg,' \
        'hole_birth,extensible_dataset,embedded_data,bookmarks,filesystem_limits,large_blocks,large_dnode,' \
        'sha512,skein,device_removal,obsolete_counts,zpool_checkpoint,spacemap_v2'
      end

      it 'returns zpool version fact' do
        result = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_version)
        expect(result).to eq('5000')
      end

      it 'returns zpool featureflags fact' do
        result = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_featureflags)
        expect(result).to eq(zpool_featureflags)
      end
    end
  end

  context 'when zpool command is not found' do
    let(:output) { 'zpool command not found' }

    it 'returns nil for zpool version fact' do
      result = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_version)
      expect(result).to eq(nil)
    end

    it 'returns nil for zpool featureversion fact' do
      result = Facter::Resolvers::Solaris::ZPool.resolve(:zpool_featurenumbers)
      expect(result).to eq(nil)
    end
  end
end
