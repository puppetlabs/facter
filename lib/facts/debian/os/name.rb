# frozen_string_literal: true

module Facter
  module Debian
    class OsName
      FACT_NAME = 'os.name'

      def call_the_resolver
        fact_value = Resolvers::LsbRelease.resolve(:distributor_id)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
