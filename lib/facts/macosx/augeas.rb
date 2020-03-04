# frozen_string_literal: true

module Facts
  module Macosx
    class Augeas
      FACT_NAME = 'augeas.version'

      def call_the_resolver
        fact_value = Facter::Resolvers::Augeas.resolve(:augeas_version)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
