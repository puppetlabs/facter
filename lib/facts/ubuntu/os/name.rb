# frozen_string_literal: true

module Facter
  module Ubuntu
    class OsName
      FACT_NAME = 'os.name'

      def call_the_resolver
        fact_value = Resolvers::LsbRelease.resolve('Distributor ID')

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
