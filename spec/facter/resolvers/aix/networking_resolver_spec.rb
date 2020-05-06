# frozen_string_literal: true

describe Facter::Resolvers::Aix::Networking do
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    Facter::Resolvers::Aix::Networking.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('netstat -rn', logger: log_spy)
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
