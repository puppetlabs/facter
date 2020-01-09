# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class SystemMemory < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        @log = Facter::Log.new(self)
        class << self
          def resolve(fact_name)
            @semaphore.synchronize do
              result ||= @fact_list[fact_name]
              subscribe_to_manager
              result || calculate_system_memory(fact_name)
            end
          end

          private

          def calculate_system_memory(fact_name)
            read_total_memory_in_bytes
            read_available_memory_in_bytes

            @fact_list[:used_bytes] = @fact_list[:total_bytes] - @fact_list[:available_bytes]
            @fact_list[:capacity] = compute_capacity(@fact_list[:used_bytes], @fact_list[:total_bytes])

            @fact_list[fact_name]
          end

          def read_available_memory_in_bytes
            output, _status = Open3.capture2('vm_stat')
            page_size = output.match(/page size of (\d+) bytes/)[1].to_i
            pages_free = output.match(/Pages free:\s+(\d+)/)[1].to_i

            @fact_list[:available_bytes] = page_size * pages_free
          end

          def read_total_memory_in_bytes
            @fact_list[:total_bytes] = Open3.capture2('sysctl -n hw.memsize').first.to_i
          end

          def compute_capacity(used, total)
            format('%.2f', (used / total.to_f * 100)) + '%'
          end
        end
      end
    end
  end
end
