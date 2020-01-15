# frozen_string_literal: true

module Facter
  module Rhel
    class Facterversion
      FACT_NAME = 'facterversion'

      def call_the_resolver
        fact_value = Resolvers::Facterversion.resolve(:facterversion)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
