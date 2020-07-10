# frozen_string_literal: true

describe Facter::Resolvers::OsLevel do
  subject(:os_level) { Facter::Resolvers::OsLevel }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    os_level.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/bin/oslevel -s', logger: log_spy)
      .and_return('build')
  end

  it 'returns build' do
    expect(os_level.resolve(:build)).to eq('build')
  end
end
