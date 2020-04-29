# frozen_string_literal: true

module Facter
  module Resolvers
    module Bsd
      class LoadAverages < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_load_averages(fact_name) }
          end

          def read_load_averages(fact_name)
            require_relative 'ffi/ffi_helper'
            @fact_list[:load_averages] = %w[1m 5m 15m].zip(Facter::Bsd::FfiHelper.read_load_averages).to_h

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
