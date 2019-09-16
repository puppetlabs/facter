# frozen_string_literal: true

module Facter
  module Macosx
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        fact_value = Resolvers::UnameResolver.resolve(:kernelname)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
