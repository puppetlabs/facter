# frozen_string_literal: true

module Facter
  module Resolvers
    class LoadAverages < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_load_averages(fact_name) }
        end

        def read_load_averages(fact_name)
          require 'facter/util/resolvers/ffi/load_averages'

          log.debug('loading cpu load averages')
          @fact_list[:load_averages] = %w[1m 5m 15m].zip(Facter::Util::Resolvers::Ffi::LoadAverages
            .read_load_averages).to_h

          @fact_list[fact_name]
        end
      end
    end
  end
end
