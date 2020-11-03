# frozen_string_literal: true

module Facter
  module Resolvers
    module Bsd
      class Processors < BaseResolver
        init_resolver
        @log = Facter::Log.new(self)

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { collect_processors_info(fact_name) }
          end

          def collect_processors_info(fact_name)
            require 'facter/resolvers/bsd/ffi/ffi_helper'

            count = logical_count
            model = processor_model
            speed = processor_speed

            @fact_list[:logical_count] = count
            @fact_list[:models] = Array.new(count, model) if count && model
            @fact_list[:speed] = speed * 1000 * 1000 if speed

            @fact_list[fact_name]
          end

          CTL_HW = 6
          HW_MODEL = 2
          HW_NCPU = 3
          HW_CPUSPEED = 12

          def processor_model
            Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_MODEL])
          end

          def logical_count
            Facter::Bsd::FfiHelper.sysctl(:uint32_t, [CTL_HW, HW_NCPU])
          end

          def processor_speed
            Facter::Bsd::FfiHelper.sysctl(:uint32_t, [CTL_HW, HW_CPUSPEED])
          end
        end
      end
    end
  end
end
