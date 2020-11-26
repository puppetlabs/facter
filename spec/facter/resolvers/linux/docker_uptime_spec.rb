# frozen_string_literal: true

describe Facter::Resolvers::Linux::DockerUptime do
  subject(:resolver) { Facter::Resolvers::Linux::DockerUptime }

  let(:log_spy) { instance_spy(Facter::Log) }

  after { Facter::Resolvers::Linux::DockerUptime.invalidate_cache }

  before do
    resolver.instance_variable_set(:@log, log_spy)
  end

  context 'when the uptime is less than 1 minutes' do
    before do
      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with('ps -o etime= -p "1"', logger: log_spy)
        .and_return('20')

      allow(Facter::Util::Resolvers::UptimeHelper)
        .to receive(:create_uptime_hash)
        .with(20)
        .and_return({ days: 0, hours: 0, seconds: 20, uptime: '0:00 hours' })
    end

    it 'returns 0 days' do
      expect(resolver.resolve(:days)).to eq(0)
    end

    it 'returns 0 hours' do
      expect(resolver.resolve(:hours)).to eq(0)
    end

    it 'returns 20 seconds' do
      expect(resolver.resolve(:seconds)).to eq(20)
    end

    it 'returns 0:00 hours for uptime' do
      expect(resolver.resolve(:uptime)).to eq('0:00 hours')
    end
  end

  context 'when the uptime is more than 1 minute and less than 1 hour' do
    before do
      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with('ps -o etime= -p "1"', logger: log_spy)
        .and_return('10:20')

      allow(Facter::Util::Resolvers::UptimeHelper)
        .to receive(:create_uptime_hash)
        .with(620)
        .and_return({ days: 0, hours: 0, seconds: 620, uptime: '0:10 hours' })
    end

    it 'returns 0 days' do
      expect(resolver.resolve(:days)).to eq(0)
    end

    it 'returns 0 hours' do
      expect(resolver.resolve(:hours)).to eq(0)
    end

    it 'returns 620 seconds' do
      expect(resolver.resolve(:seconds)).to eq(620)
    end

    it 'returns 0:10 hours for uptime' do
      expect(resolver.resolve(:uptime)).to eq('0:10 hours')
    end
  end

  context 'when the uptime is more than 1 hour but less than 1 day' do
    before do
      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with('ps -o etime= -p "1"', logger: log_spy)
        .and_return('3:10:20')

      allow(Facter::Util::Resolvers::UptimeHelper)
        .to receive(:create_uptime_hash)
        .with(11_420)
        .and_return({ days: 0, hours: 3, seconds: 11_420, uptime: '3:10 hours' })
    end

    it 'returns 0 days' do
      expect(resolver.resolve(:days)).to eq(0)
    end

    it 'returns 3 hours' do
      expect(resolver.resolve(:hours)).to eq(3)
    end

    it 'returns 11420 seconds' do
      expect(resolver.resolve(:seconds)).to eq(11_420)
    end

    it 'returns 3:10 hours for uptime' do
      expect(resolver.resolve(:uptime)).to eq('3:10 hours')
    end
  end

  context 'when the uptime is 1 day' do
    before do
      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with('ps -o etime= -p "1"', logger: log_spy)
        .and_return('1-3:10:20')

      allow(Facter::Util::Resolvers::UptimeHelper)
        .to receive(:create_uptime_hash)
        .with(97_820)
        .and_return({ days: 1, hours: 27, seconds: 97_820, uptime: '1 day' })
    end

    it 'returns 1 day' do
      expect(resolver.resolve(:days)).to eq(1)
    end

    it 'returns 27 hours' do
      expect(resolver.resolve(:hours)).to eq(27)
    end

    it 'returns 97820 seconds' do
      expect(resolver.resolve(:seconds)).to eq(97_820)
    end

    it 'returns 1 day for uptime' do
      expect(resolver.resolve(:uptime)).to eq('1 day')
    end
  end

  context 'when the uptime is more than 2 day' do
    before do
      allow(Facter::Core::Execution)
        .to receive(:execute)
        .with('ps -o etime= -p "1"', logger: log_spy)
        .and_return('2-3:10:20')

      allow(Facter::Util::Resolvers::UptimeHelper)
        .to receive(:create_uptime_hash)
        .with(184_220)
        .and_return({ days: 2, hours: 51, seconds: 184_220, uptime: '2 days' })
    end

    it 'returns 2 days' do
      expect(resolver.resolve(:days)).to eq(2)
    end

    it 'returns 51 hours' do
      expect(resolver.resolve(:hours)).to eq(51)
    end

    it 'returns 184220 seconds' do
      expect(resolver.resolve(:seconds)).to eq(184_220)
    end

    it 'returns 2 days for uptime' do
      expect(resolver.resolve(:uptime)).to eq('2 days')
    end
  end
end
