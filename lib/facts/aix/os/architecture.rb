# frozen_string_literal: true

module Facter
  module Aix
    class OsArchitecture
      FACT_NAME = 'os.architecture'

      def call_the_resolver
        fact_value = Resolvers::Architecture.resolve(:architecture)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
