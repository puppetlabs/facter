# frozen_string_literal: true

describe Facter::Resolvers::Macosx::LoadAverages do
  subject(:load_averages) { Facter::Resolvers::Macosx::LoadAverages }

  let(:expected_result) { { '1m' => 0.00, '5m' => 0.03, '15m' => 0.03 } }

  before do
    allow(Facter::Core::Execution).to receive(:execute)
      .with('sysctl -n vm.loadavg', logger: an_instance_of(Facter::Log))
      .and_return('{ 0.00 0.03 0.03 }')
  end

  it 'returns load average' do
    expect(load_averages.resolve(:load_averages)).to eq(expected_result)
  end
end
