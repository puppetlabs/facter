# frozen_string_literal: true

describe 'UptimeResolver' do
  after { Facter::Resolvers::Uptime.invalidate_cache }

  describe 'all uptime stats' do
    before { allow(Facter::UptimeParser).to receive(:uptime_seconds_unix) { 86_500 } }

    it 'returns uptime in days' do
      expect(Facter::Resolvers::Uptime.resolve(:days)).to eq(1)
    end

    it 'returns uptime in hours' do
      expect(Facter::Resolvers::Uptime.resolve(:hours)).to eq(24)
    end

    it 'returns uptime in seconds' do
      expect(Facter::Resolvers::Uptime.resolve(:seconds)).to eq(86_500)
    end

    context 'when we do not input seconds' do
      it 'returns "uknown" uptime value' do
        allow(Facter::UptimeParser).to receive(:uptime_seconds_unix) { nil }

        expect(Facter::Resolvers::Uptime.resolve(:uptime)).to eq('unknown')
      end
    end
  end

  describe 'uptime text description' do
    context 'when the parsed seconds are less than a day' do
      it 'returns the hours as a text' do
        allow(Facter::UptimeParser).to receive(:uptime_seconds_unix) { 21_660 }

        expect(Facter::Resolvers::Uptime.resolve(:uptime)).to eq('6:01 hours')
      end
    end

    context 'when the parsed seconds are between 1 and 2 days' do
      it 'returns "1 day" as a text' do
        allow(Facter::UptimeParser).to receive(:uptime_seconds_unix) { 86_500 }

        expect(Facter::Resolvers::Uptime.resolve(:uptime)).to eq('1 day')
      end
    end

    context 'when the parsed seconds are more than 2 days' do
      it 'returns the number of days as a text' do
        allow(Facter::UptimeParser).to receive(:uptime_seconds_unix) { 186_500 }

        expect(Facter::Resolvers::Uptime.resolve(:uptime)).to eq('2 days')
      end
    end
  end
end
