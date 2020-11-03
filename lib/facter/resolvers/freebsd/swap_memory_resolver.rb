# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class SwapMemory < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_swap_memory(fact_name) }
          end

          def read_swap_memory(fact_name) # rubocop:disable Metrics/AbcSize
            output = Facter::Core::Execution.execute('swapinfo -k', logger: log)
            data = output.split("\n")[1..-1].map { |line| line.split(/\s+/) }

            unless data.empty?
              @fact_list[:total_bytes]     = kilobytes_to_bytes(data.map { |line| line[1].to_i }.inject(:+))
              @fact_list[:used_bytes]      = kilobytes_to_bytes(data.map { |line| line[2].to_i }.inject(:+))
              @fact_list[:available_bytes] = kilobytes_to_bytes(data.map { |line| line[3].to_i }.inject(:+))
              @fact_list[:capacity] = FilesystemHelper.compute_capacity(@fact_list[:used_bytes],
                                                                        @fact_list[:total_bytes])
              @fact_list[:encrypted] = data.map { |line| line[0].end_with?('.eli') }.all?
            end

            @fact_list[fact_name]
          end

          def kilobytes_to_bytes(quantity)
            (quantity.to_f * 1024).to_i
          end
        end
      end
    end
  end
end
