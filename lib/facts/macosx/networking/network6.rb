# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Network6
        FACT_NAME = 'networking.network6'
        ALIASES = 'network6'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::Networking.resolve(:network6)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
