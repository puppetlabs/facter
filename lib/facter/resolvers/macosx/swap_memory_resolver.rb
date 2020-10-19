# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class SwapMemory < BaseResolver
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_swap_memory(fact_name) }
          end

          def read_swap_memory(fact_name) # rubocop:disable Metrics/AbcSize
            output = Facter::Core::Execution.execute('sysctl -n vm.swapusage', logger: log)
            data = output.match(/^total = ([\d.]+)M  used = ([\d.]+)M  free = ([\d.]+)M  (\(encrypted\))$/)

            if data[1].to_f.positive?
              @fact_list[:total_bytes] = megabytes_to_bytes(data[1])
              @fact_list[:used_bytes] = megabytes_to_bytes(data[2])
              @fact_list[:available_bytes] = megabytes_to_bytes(data[3])
              @fact_list[:capacity] = compute_capacity(@fact_list[:used_bytes], @fact_list[:total_bytes])
              @fact_list[:encrypted] = data[4] == '(encrypted)'
            end

            @fact_list[fact_name]
          end

          def megabytes_to_bytes(quantity)
            (quantity.to_f * 1_048_576).to_i
          end

          def compute_capacity(used, total)
            "#{format('%<value>.2f', value: (used / total.to_f * 100))}%"
          end
        end
      end
    end
  end
end
