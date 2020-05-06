# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class SystemMemory < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { calculate_system_memory(fact_name) }
          end

          def calculate_system_memory(fact_name)
            read_total_memory_in_bytes
            read_available_memory_in_bytes

            @fact_list[:used_bytes] = @fact_list[:total_bytes] - @fact_list[:available_bytes]
            @fact_list[:capacity] = compute_capacity(@fact_list[:used_bytes], @fact_list[:total_bytes])

            @fact_list[fact_name]
          end

          def read_available_memory_in_bytes
            output = Facter::Core::Execution.execute('vm_stat', logger: log)
            page_size = output.match(/page size of (\d+) bytes/)[1].to_i
            pages_free = output.match(/Pages free:\s+(\d+)/)[1].to_i

            @fact_list[:available_bytes] = page_size * pages_free
          end

          def read_total_memory_in_bytes
            @fact_list[:total_bytes] = Facter::Core::Execution.execute('sysctl -n hw.memsize', logger: log).to_i
          end

          def compute_capacity(used, total)
            format('%.2f', (used / total.to_f * 100)) + '%'
          end
        end
      end
    end
  end
end
