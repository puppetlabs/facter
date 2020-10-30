# frozen_string_literal: true

module Facter
  module Resolvers
    class Ruby < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_ruby_information(fact_name) }
        end

        def retrieve_ruby_information(fact_name)
          @fact_list[:sitedir] = RbConfig::CONFIG['sitelibdir']
          @fact_list[:platform] = RUBY_PLATFORM
          @fact_list[:version] = RUBY_VERSION
          @fact_list[fact_name]
        end
      end
    end
  end
end
