# frozen_string_literal: true

describe Facter::Util::Resolvers::UptimeHelper do
  subject(:helper) { Facter::Util::Resolvers::UptimeHelper }

  context 'when the uptime is less than 1 minutes' do
    let(:expected_result) { { days: 0, hours: 0, seconds: 20, uptime: '0:00 hours' } }

    it 'returns response hash' do
      expect(helper.create_uptime_hash(20)).to eq(expected_result)
    end
  end

  context 'when the uptime is more than 1 minute and less than 1 hour' do
    let(:expected_result) { { days: 0, hours: 0, seconds: 620, uptime: '0:10 hours' } }

    it 'returns response hash' do
      expect(helper.create_uptime_hash(620)).to eq(expected_result)
    end
  end

  context 'when the uptime is more than 1 hour but less than 1 day' do
    let(:expected_result) { { days: 0, hours: 3, seconds: 11_420, uptime: '3:10 hours' } }

    it 'returns response hash' do
      expect(helper.create_uptime_hash(11_420)).to eq(expected_result)
    end
  end

  context 'when the uptime is 1 day' do
    let(:expected_result) { { days: 1, hours: 27, seconds: 97_820, uptime: '1 day' } }

    it 'returns response hash' do
      expect(helper.create_uptime_hash(97_820)).to eq(expected_result)
    end
  end

  context 'when the uptime is more than 2 day' do
    let(:expected_result) { { days: 2, hours: 51, seconds: 184_220, uptime: '2 days' } }

    it 'returns response hash' do
      expect(helper.create_uptime_hash(184_220)).to eq(expected_result)
    end
  end
end
