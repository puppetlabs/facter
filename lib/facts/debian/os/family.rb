# frozen_string_literal: true

module Facter
  module Debian
    class OsFamily
      FACT_NAME = 'os.family'
      ALIASES = 'osfamily'

      def call_the_resolver
        fact_value = Resolvers::OsRelease.resolve(:id_like)
        fact_value ||= Resolvers::OsRelease.resolve(:id)

        [ResolvedFact.new(FACT_NAME, fact_value.capitalize), ResolvedFact.new(ALIASES, fact_value.capitalize, :legacy)]
      end
    end
  end
end
