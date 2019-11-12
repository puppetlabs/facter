# frozen_string_literal: true

describe 'LoadAverageResolver' do
  let(:loadavrg) { { '1min' => '0.00', '5min' => '0.03', '15min' => '0.03' } }

  before do
    allow(File).to receive(:read)
      .with('/proc/loadavg')
      .and_return(load_fixture('loadavg').read)
  end
  it 'returns load average' do
    result = Facter::Resolvers::Linux::LoadAverage.resolve(:loadavrg)

    expect(result).to eq(loadavrg)
  end
end
