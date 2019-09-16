# frozen_string_literal: true

module Facter
  module Opensuse
    class OsName
      FACT_NAME = 'os.name'

      def call_the_resolver
        fact_value = Resolver::LsbReleaseResolver.resolve('Distributor ID')

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
