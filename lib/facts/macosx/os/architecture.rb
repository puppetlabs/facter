# frozen_string_literal: true

module Facter
  module Macosx
    class OsArchitecture
      FACT_NAME = 'os.architecture'
      ALIASES = 'architecture'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:machine)
        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
