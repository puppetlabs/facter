# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class SystemMemory < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { calculate_system_memory(fact_name) }
          end

          def calculate_system_memory(fact_name)
            read_total_memory_in_bytes
            read_available_memory_in_bytes

            @fact_list[:used_bytes] = @fact_list[:total_bytes] - @fact_list[:available_bytes]
            @fact_list[:capacity] = Facter::Util::Resolvers::FilesystemHelper
                                    .compute_capacity(@fact_list[:used_bytes], @fact_list[:total_bytes])

            @fact_list[fact_name]
          end

          def read_available_memory_in_bytes
            output = Facter::Core::Execution.execute('vmstat -H --libxo json', logger: log)
            data = JSON.parse(output)
            @fact_list[:available_bytes] = data['memory']['free-memory'] * 1024
          end

          def read_total_memory_in_bytes
            require_relative 'ffi/ffi_helper'

            @fact_list[:total_bytes] = Facter::Freebsd::FfiHelper.sysctl_by_name(:long, 'hw.physmem')
          end
        end
      end
    end
  end
end
