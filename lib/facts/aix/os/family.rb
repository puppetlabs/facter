# frozen_string_literal: true

module Facter
  module Aix
    class OsFamily
      FACT_NAME = 'os.family'
      ALIASES = 'osfamily'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelname)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
