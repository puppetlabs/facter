# frozen_string_literal: true

require 'resolvers/bsd/processors'

module Facter
  module Resolvers
    module Freebsd
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
            require "#{ROOT_DIR}/lib/resolvers/freebsd/ffi/ffi_helper"

            @fact_list[:logical_count] = logical_count
            @fact_list[:models] = Array.new(logical_count, model) if logical_count && model
            @fact_list[:speed] = speed * 1000 * 1000 if speed

            @fact_list[fact_name]
          end

          def model
            @model ||= Facter::Freebsd::FfiHelper.sysctl_by_name(:string, 'hw.model')
          end

          def logical_count
            @logical_count ||= Facter::Freebsd::FfiHelper.sysctl_by_name(:uint32_t, 'hw.ncpu')
          end

          def speed
            @speed ||= Facter::Freebsd::FfiHelper.sysctl_by_name(:uint32_t, 'hw.clockrate')
          end
        end
      end
    end
  end
end
