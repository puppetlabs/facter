# frozen_string_literal: true

module Facter
  module Debian
    class OsName
      FACT_NAME = 'os.name'
      ALIASES = 'operatingsystem'

      def call_the_resolver
        fact_value = Resolvers::LsbRelease.resolve(:distributor_id)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
