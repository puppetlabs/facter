# frozen_string_literal: true

module Facts
  module Sles
    module Augeas
      class Version
        FACT_NAME = 'augeas.version'
        ALIASES = 'augeasversion'

        def call_the_resolver
          fact_value = Facter::Resolvers::Augeas.resolve(:augeas_version)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value),
           Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
