# frozen_string_literal: true

module Facter
  module Resolvers
    class Memory < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || validate_info(fact_name)
          end
        end

        private

        def read_performance_information
          state_ptr = FFI::MemoryPointer.new(PerformanceInformation.size)
          if MemoryFFI::GetPerformanceInfo(state_ptr, state_ptr.size) == FFI::WIN32_FALSE
            @log.debug 'Resolving memory facts failed'
            return
          end

          PerformanceInformation.new(state_ptr)
        end

        def calculate_memory
          state = read_performance_information
          return unless state

          total_bytes = state[:PhysicalTotal] * state[:PageSize]
          available_bytes = state[:PhysicalAvailable] * state[:PageSize]
          if total_bytes.zero? || available_bytes.zero?
            @log.debug 'Available or Total bytes are zero could not proceed further'
            return
          end

          { total_bytes: total_bytes, available_bytes: available_bytes, used_bytes: total_bytes - available_bytes }
        end

        def validate_info(fact_name)
          result = calculate_memory
          return unless result

          build_facts_list(result)
          @fact_list[fact_name]
        end

        def build_facts_list(result)
          @fact_list[:total_bytes] = result[:total_bytes]
          @fact_list[:available_bytes] = result[:available_bytes]
          @fact_list[:used_bytes] = result[:used_bytes]
          @fact_list[:capacity] = format('%<capacity>.2f',
                                         capacity: (result[:used_bytes] / result[:total_bytes].to_f * 100)) + '%'
        end
      end
    end
  end
end
