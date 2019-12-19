# frozen_string_literal: true

module Facter
  module Aix
    class AugeasVersion
      FACT_NAME = 'augeas.version'

      def call_the_resolver
        fact_value = Resolvers::Augeas.resolve(:augeas_version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
