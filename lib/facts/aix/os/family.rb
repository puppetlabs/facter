# frozen_string_literal: true

module Facter
  module Aix
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelname)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
