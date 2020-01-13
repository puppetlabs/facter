# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class LoadAverages < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || read_load_averages(fact_name)
            end
          end

          private

          def read_load_averages(fact_name)
            @fact_list[:load_averages] = {}.tap do |h|
              h['1m'], h['5m'], h['15m'] = Facter::Aix::FfiHelper.read_load_averages
            end

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
