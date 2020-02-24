# frozen_string_literal: true

describe Facter::Resolvers::Linux::LoadAverages do
  let(:load_averages) { { '1m' => 0.00, '5m' => 0.03, '15m' => 0.03 } }

  before do
    allow(File).to receive(:read)
      .with('/proc/loadavg')
      .and_return(load_fixture('loadavg').read)
  end

  it 'returns load average' do
    result = Facter::Resolvers::Linux::LoadAverages.resolve(:load_averages)

    expect(result).to eq(load_averages)
  end
end
