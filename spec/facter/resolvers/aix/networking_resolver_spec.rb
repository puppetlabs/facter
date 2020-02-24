# frozen_string_literal: true

describe Facter::Resolvers::Aix::Networking do
  before do
    allow(Open3).to receive(:capture2)
      .with('netstat -rn')
      .and_return(load_fixture('netstat_rn').read)
  end

  it 'returns primary interface' do
    result = Facter::Resolvers::Aix::Networking.resolve(:primary)

    expect(result).to eq('en0')
  end

  it 'returns ipv4 for primary interface' do
    result = Facter::Resolvers::Aix::Networking.resolve(:ip)

    expect(result).to eq('10.32.77.40')
  end
end
