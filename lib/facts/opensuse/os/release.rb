# frozen_string_literal: true

module Facter
  module Opensuse
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        fact_value = Resolvers::UnameResolver.resolve(:release)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
