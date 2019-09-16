# frozen_string_literal: true

module Facter
  module Opensuse
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        fact_value = Resolver::OsReleaseResolver.resolve('ID')

        ResolvedFact.new(FACT_NAME, fact_value.capitalize)
      end
    end
  end
end
