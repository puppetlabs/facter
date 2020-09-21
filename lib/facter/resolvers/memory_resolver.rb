# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Memory < BaseResolver
        @fact_list ||= {}
        @log = Facter::Log.new(self)
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_meminfo_file(fact_name) }
          end

          def read_meminfo_file(fact_name)
            meminfo_output = Util::FileHelper.safe_read('/proc/meminfo', nil)
            return unless meminfo_output

            read_system(meminfo_output)
            read_swap(meminfo_output)

            @fact_list[fact_name]
          end

          def read_system(output)
            @fact_list[:total] = kilobytes_to_bytes(output.match(/MemTotal:\s+(\d+)\s/)[1])
            @fact_list[:memfree] = kilobytes_to_bytes(output.match(/MemFree:\s+(\d+)\s/)[1])
            @fact_list[:used_bytes] = compute_used(@fact_list[:total], reclaimable_memory(output))
            @fact_list[:capacity] = compute_capacity(@fact_list[:used_bytes], @fact_list[:total])
          end

          def read_swap(output)
            total = output.match(/SwapTotal:\s+(\d+)\s/)[1]
            return if total.to_i.zero?

            @fact_list[:swap_total] = kilobytes_to_bytes(total)
            @fact_list[:swap_free] = kilobytes_to_bytes(output.match(/SwapFree:\s+(\d+)\s/)[1])
            @fact_list[:swap_used_bytes] = compute_used(@fact_list[:swap_total], @fact_list[:swap_free])
            @fact_list[:swap_capacity] = compute_capacity(@fact_list[:swap_used_bytes], @fact_list[:swap_total])
          end

          def kilobytes_to_bytes(quantity)
            quantity.to_i * 1024
          end

          def reclaimable_memory(output)
            buffers = kilobytes_to_bytes(output.match(/Buffers:\s+(\d+)\s/)[1])
            cached = kilobytes_to_bytes(output.match(/Cached:\s+(\d+)\s/)[1])
            s_reclaimable = output.match(/SReclaimable:\s+(\d+)\s/)
            s_reclaimable = if s_reclaimable
                              kilobytes_to_bytes(s_reclaimable[1])
                            else
                              0
                            end
            @fact_list[:memfree] + buffers + cached + s_reclaimable
          end

          def compute_capacity(used, total)
            capacity = (used / total.to_f * 100)
            return '0%' if capacity.zero?

            format('%<computed_capacity>.2f', computed_capacity: capacity) + '%'
          end

          def compute_used(total, free)
            total - free
          end
        end
      end
    end
  end
end
