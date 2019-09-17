# frozen_string_literal: true

module Facter
  module Resolvers
    class MemoryResolver < BaseResolver
      @log = Facter::Log.new
      class << self
        @@semaphore = Mutex.new
        @@fact_list ||= {}

        def resolve(fact_name)
          @@semaphore.synchronize do
            result ||= @@fact_list[fact_name]
            result || validate_info(fact_name)
          end
        end

        def invalidate_cache
          @@fact_list = {}
        end

        private

        def read_performance_information
          state_ptr = FFI::MemoryPointer.new(PerformanceInformation.size)
          if MemoryFFI::GetPerformanceInfo(state_ptr, state_ptr.size) == FFI::WIN32_FALSE
            @log.debug 'Resolving memory facts failed'
            return
          end

          state = PerformanceInformation.new(state_ptr)
          total_bytes = state[:PhysicalTotal] * state[:PageSize]
          available_bytes = state[:PhysicalAvailable] * state[:PageSize]
          { total_bytes: total_bytes, available_bytes: available_bytes, used_bytes: total_bytes - available_bytes }
        end

        def validate_info(fact_name)
          result = read_performance_information
          return unless result

          build_facts_list(result)
          @@fact_list[fact_name]
        end

        def build_facts_list(result)
          @@fact_list[:total_bytes] = result[:total_bytes]
          @@fact_list[:available_bytes] = result[:available_bytes]
          @@fact_list[:used_bytes] = result[:used_bytes]
          @@fact_list[:capacity] = format('%.2f', (result[:used_bytes] / result[:total_bytes].to_f * 100)) + '%'
        end
      end
    end
  end
end
