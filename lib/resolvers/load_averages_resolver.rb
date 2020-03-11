# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class LoadAverages < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_load_averages_file(fact_name) }
          end

          def read_load_averages_file(fact_name)
            return unless File.readable?('/proc/loadavg')

            output = File.read('/proc/loadavg')
            @fact_list[:load_averages] = {}.tap { |h| h['1m'], h['5m'], h['15m'], = output.split.map(&:to_f) }

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
