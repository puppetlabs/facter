# frozen_string_literal: true

describe Facter::Resolvers::Aix::OsLevel do
  subject(:os_level) { Facter::Resolvers::Aix::OsLevel }

  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    os_level.instance_variable_set(:@log, log_spy)
    allow(Facter::Core::Execution).to receive(:execute)
      .with('/usr/bin/oslevel -s', { limit: 2, logger: log_spy })
      .and_return(output)
  end

  after do
    os_level.invalidate_cache
  end

  describe 'when command returns an output' do
    let(:output) { '6100-09-00-0000' }

    it 'returns build' do
      expect(os_level.resolve(:build)).to eq(output)
    end
  end

  describe 'when command returns empty string' do
    let(:output) { '' }

    it 'returns build as nil' do
      expect(os_level.resolve(:build)).to be_nil
    end
  end
end
