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
            averages = File.read('/proc/loadavg').split(' ')

            result = {
              '1m' => averages[0],
              '5m' => averages[1],
              '15m' => averages[2]
            }

            @fact_list[:load_averages] = result
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
