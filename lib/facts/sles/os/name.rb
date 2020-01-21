# frozen_string_literal: true

module Facter
  module Sles
    class OsName
      FACT_NAME = 'os.name'
      ALIASES = 'operatingsystem'

      def call_the_resolver
        fact_value = Resolvers::OsRelease.resolve(:name)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
