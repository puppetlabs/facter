# frozen_string_literal: true

describe Facter::Resolvers::Linux::LoadAverages do
  let(:load_averages) { { '1m' => '0.00', '5m' => '0.03', '15m' => '0.03' } }
  let(:no_load_averages) { { '1m' => nil, '5m' => nil, '15m' => nil } }

  after do
    Facter::Resolvers::Linux::LoadAverages.invalidate_cache
  end

  context 'when /proc/loadavg is accessible' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/proc/loadavg')
        .and_return(load_fixture('loadavg').read)
    end

    it 'returns load average' do
      result = Facter::Resolvers::Linux::LoadAverages.resolve(:load_averages)

      expect(result).to eq(load_averages)
    end
  end

  context 'when /proc/loadavg is not accessible' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_read)
        .with('/proc/loadavg')
        .and_return('')
    end

    it 'returns no load averages' do
      result = Facter::Resolvers::Linux::LoadAverages.resolve(:load_averages)

      expect(result).to eq(no_load_averages)
    end
  end
end
