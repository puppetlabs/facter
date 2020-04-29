# frozen_string_literal: true

describe Facter::Resolvers::Bsd::LoadAverages do
  let(:load_averages) { [0.01, 0.02, 0.03] }

  before do
    allow(Facter::Bsd::FfiHelper).to receive(:read_load_averages)
      .and_return(load_averages)
  end

  it 'returns load average' do
    result = Facter::Resolvers::Bsd::LoadAverages.resolve(:load_averages)

    expect(result).to eq('15m' => 0.03, '1m' => 0.01, '5m' => 0.02)
  end
end
