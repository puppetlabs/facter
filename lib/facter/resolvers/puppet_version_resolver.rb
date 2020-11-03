# frozen_string_literal: true

module Facter
  module Resolvers
    class PuppetVersionResolver < BaseResolver
      # :puppetversion

      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { puppet_version(fact_name) }
        end

        def puppet_version(fact_name)
          require 'puppet/version'
          @fact_list[:puppetversion] = Puppet.version

          @fact_list[fact_name]
        end
      end
    end
  end
end
