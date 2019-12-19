# frozen_string_literal: true

describe 'LoadAveragesResolver' do
  let(:load_averages) { { '1m' => 0.00, '5m' => 0.03, '15m' => 0.03 } }

  before do
    allow(Open3).to receive(:capture2)
      .with('sysctl -n vm.loadavg')
      .and_return('{ 0.00 0.03 0.03 }')
  end

  it 'returns load average' do
    result = Facter::Resolvers::Macosx::LoadAverages.resolve(:load_averages)

    expect(result).to eq(load_averages)
  end
end
