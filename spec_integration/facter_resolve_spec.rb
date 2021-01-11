# frozen_string_literal: true

require_relative 'integration_helper'

describe Facter do
  context 'when calling the ruby API resolve' do
    it 'returns a hash that includes legacy values' do
      result = Facter.resolve('--show-legacy')

      expect(result['uptime_hours']).not_to be_nil
    end

    it "returns a hash that doesn't include legacy values" do
      result = Facter.resolve('--show-legacy false')

      expect(result['uptime_hours']).to be_nil
    end
  end
end
