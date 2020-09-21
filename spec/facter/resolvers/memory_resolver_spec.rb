# frozen_string_literal: true

describe Facter::Resolvers::Linux::Memory do
  subject(:resolver) { Facter::Resolvers::Linux::Memory }

  after do
    Facter::Resolvers::Linux::Memory.invalidate_cache
  end

  context 'when file /proc/meminfo is readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/proc/meminfo', nil)
        .and_return(load_fixture(fixture_name).read)
    end

    context 'when there is swap memory' do
      let(:total) { 4_036_680 * 1024 }
      let(:free) { 3_547_792 * 1024 }
      let(:buffers) { 4_288 * 1024 }
      let(:cached) { 298_624 * 1024 }
      let(:s_reclaimable) { 29_072 * 1024 }
      let(:used) { total - free - buffers - cached - s_reclaimable }
      let(:swap_total) { 2_097_148 * 1024 }
      let(:swap_free) { 2_097_148 * 1024 }
      let(:swap_used) { swap_total - swap_free }
      let(:fixture_name) { 'meminfo' }

      it 'returns total memory' do
        expect(resolver.resolve(:total)).to eq(total)
      end

      it 'returns memfree' do
        expect(resolver.resolve(:memfree)).to eq(free)
      end

      it 'returns swap total' do
        expect(resolver.resolve(:swap_total)).to eq(swap_total)
      end

      it 'returns swap available' do
        expect(resolver.resolve(:swap_free)).to eq(swap_free)
      end

      it 'returns swap capacity' do
        swap_capacity = '0%'

        expect(resolver.resolve(:swap_capacity)).to eq(swap_capacity)
      end

      it 'returns swap usage' do
        expect(resolver.resolve(:swap_used_bytes)).to eq(swap_used)
      end

      it 'returns system capacity' do
        system_capacity = format('%<capacity>.2f', capacity: (used / total.to_f * 100)) + '%'

        expect(resolver.resolve(:capacity)).to eq(system_capacity)
      end

      it 'returns system usage' do
        expect(resolver.resolve(:used_bytes)).to eq(used)
      end
    end

    context 'when there is not swap memory' do
      let(:total) { 4_134_510_592 }
      let(:free) { 3_465_723_904 }
      let(:buffers) { 2_088 * 1024 }
      let(:cached) { 445_204 * 1024 }
      let(:s_reclaimable) { 71_384 * 1024 }
      let(:used) { total - free - buffers - cached - s_reclaimable }
      let(:fixture_name) { 'meminfo2' }

      it 'returns total memory' do
        expect(resolver.resolve(:total)).to eq(total)
      end

      it 'returns memfree' do
        expect(resolver.resolve(:memfree)).to eq(free)
      end

      it 'returns swap total as nil' do
        expect(resolver.resolve(:swap_total)).to eq(nil)
      end

      it 'returns swap available as nil' do
        expect(resolver.resolve(:swap_free)).to eq(nil)
      end

      it 'returns swap capacity as nil' do
        expect(resolver.resolve(:swap_capacity)).to eq(nil)
      end

      it 'returns swap usage as nil' do
        expect(resolver.resolve(:swap_used_bytes)).to eq(nil)
      end

      it 'returns system capacity' do
        system_capacity = format('%<capacity>.2f', capacity: (used / total.to_f * 100)) + '%'

        expect(resolver.resolve(:capacity)).to eq(system_capacity)
      end

      it 'returns system usage' do
        expect(resolver.resolve(:used_bytes)).to eq(used)
      end
    end

    context 'when on Rhel 5' do
      let(:total) { 4_036_680 * 1024 }
      let(:free) { 3_547_792 * 1024 }
      let(:buffers) { 4_288 * 1024 }
      let(:cached) { 298_624 * 1024 }
      let(:s_reclaimable) { 0 }
      let(:used) { total - free - buffers - cached - s_reclaimable }
      let(:swap_total) { 2_097_148 * 1024 }
      let(:swap_free) { 2_097_100 * 1024 }
      let(:swap_used) { swap_total - swap_free }
      let(:fixture_name) { 'rhel5_memory' }

      it 'returns total memory' do
        expect(resolver.resolve(:total)).to eq(total)
      end

      it 'returns memfree' do
        expect(resolver.resolve(:memfree)).to eq(free)
      end

      it 'returns swap total' do
        expect(resolver.resolve(:swap_total)).to eq(swap_total)
      end

      it 'returns swap available' do
        expect(resolver.resolve(:swap_free)).to eq(swap_free)
      end

      it 'returns swap capacity' do
        swap_capacity = format('%<swap_capacity>.2f', swap_capacity: (swap_used / swap_total.to_f * 100)) + '%'

        expect(resolver.resolve(:swap_capacity)).to eq(swap_capacity)
      end

      it 'returns swap usage' do
        expect(resolver.resolve(:swap_used_bytes)).to eq(swap_used)
      end

      it 'returns system capacity' do
        system_capacity = format('%<capacity>.2f', capacity: (used / total.to_f * 100)) + '%'

        expect(resolver.resolve(:capacity)).to eq(system_capacity)
      end

      it 'returns system usage' do
        expect(resolver.resolve(:used_bytes)).to eq(used)
      end
    end
  end

  context 'when file /proc/meminfo is not readable' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/proc/meminfo', nil)
        .and_return(nil)
    end

    it 'returns swap available as nil' do
      expect(resolver.resolve(:swap_free)).to be(nil)
    end

    it 'returns system usage as nil' do
      expect(resolver.resolve(:used_bytes)).to be(nil)
    end
  end
end
