# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class LoadAverages < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || read_load_averages_file(fact_name)
            end
          end

          private

          def read_load_averages_file(fact_name)
            output = File.read('/proc/loadavg')
            @fact_list[:load_averages] = {}.tap { |h| h['1m'], h['5m'], h['15m'], = output.split.map(&:to_f) }

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
