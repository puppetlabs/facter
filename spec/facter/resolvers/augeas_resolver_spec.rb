# frozen_string_literal: true

describe Facter::Resolvers::Augeas do
  subject(:augeas) { Facter::Resolvers::Augeas }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    augeas.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('augparse --version 2>&1', logger: log_spy)
      .and_return('augparse 1.12.0 <http://augeas.net/>')
  end

  it 'returns build' do
    expect(augeas.resolve(:augeas_version)).to eq('1.12.0')
  end
end
