# frozen_string_literal: true

module Facter
  module Resolvers
    module Bsd
      class Processors < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { collect_processors_info(fact_name) }
          end

          def collect_processors_info(fact_name)
            require "#{ROOT_DIR}/lib/resolvers/bsd/ffi/ffi_helper"

            @fact_list[:logical_count] = logical_count
            @fact_list[:models] = Array.new(logical_count, model) if logical_count && model
            @fact_list[:speed] = speed * 1000 * 1000 if speed

            @fact_list[fact_name]
          end

          CTL_HW = 6
          HW_MODEL = 2
          HW_NCPU = 3
          HW_CPUSPEED = 12

          def model
            @model ||= Facter::Bsd::FfiHelper.sysctl(:string, [CTL_HW, HW_MODEL])
          end

          def logical_count
            @logical_count ||= Facter::Bsd::FfiHelper.sysctl(:uint32_t, [CTL_HW, HW_NCPU])
          end

          def speed
            @speed ||= Facter::Bsd::FfiHelper.sysctl(:uint32_t, [CTL_HW, HW_CPUSPEED])
          end
        end
      end
    end
  end
end
