# frozen_string_literal: true

module Facter
  module Resolvers
    module Freebsd
      class SystemMemory < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { calculate_system_memory(fact_name) }
          end

          def calculate_system_memory(fact_name)
            read_total_memory_in_bytes
            read_used_memory_in_bytes

            @fact_list[:available_bytes] = @fact_list[:total_bytes] - @fact_list[:used_bytes]
            @fact_list[:capacity] = Facter::Util::Resolvers::FilesystemHelper
                                    .compute_capacity(@fact_list[:used_bytes], @fact_list[:total_bytes])

            @fact_list[fact_name]
          end

          def pagesize
            @pagesize ||= Facter::Freebsd::FfiHelper.sysctl_by_name(:long, 'vm.stats.vm.v_page_size')
          end

          def read_used_memory_in_bytes
            require_relative 'ffi/ffi_helper'

            @fact_list[:used_bytes] = pagesize * (
              Facter::Freebsd::FfiHelper.sysctl_by_name(:long, 'vm.stats.vm.v_active_count') +
              Facter::Freebsd::FfiHelper.sysctl_by_name(:long, 'vm.stats.vm.v_wire_count')
            )
          end

          def read_total_memory_in_bytes
            require_relative 'ffi/ffi_helper'

            @fact_list[:total_bytes] = pagesize *
                                       Facter::Freebsd::FfiHelper.sysctl_by_name(:long, 'vm.stats.vm.v_page_count')
          end
        end
      end
    end
  end
end
