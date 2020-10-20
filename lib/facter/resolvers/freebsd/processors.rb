# frozen_string_literal: true

require 'facter/resolvers/bsd/processors'

module Facter
  module Resolvers
    module Freebsd
      class Processors < BaseResolver
        @log = Facter::Log.new(self)
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { collect_processors_info(fact_name) }
          end

          def collect_processors_info(fact_name)
            require 'facter/resolvers/freebsd/ffi/ffi_helper'

            count = logical_count
            model = processors_model
            speed = processors_speed

            @fact_list[:logical_count] = count
            @fact_list[:models] = Array.new(count, model) if logical_count && model
            @fact_list[:speed] = speed * 1000 * 1000 if speed

            @fact_list[fact_name]
          end

          def processors_model
            Facter::Freebsd::FfiHelper.sysctl_by_name(:string, 'hw.model')
          end

          def logical_count
            Facter::Freebsd::FfiHelper.sysctl_by_name(:uint32_t, 'hw.ncpu')
          end

          def processors_speed
            Facter::Freebsd::FfiHelper.sysctl_by_name(:uint32_t, 'hw.clockrate')
          end
        end
      end
    end
  end
end
