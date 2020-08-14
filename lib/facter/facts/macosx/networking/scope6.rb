# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Scope6
        FACT_NAME = 'networking.scope6'

        def call_the_resolver
          fact_value = Facter::Resolvers::Networking.resolve(:scope6)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
