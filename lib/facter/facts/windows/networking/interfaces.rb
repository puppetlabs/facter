# frozen_string_literal: true

module Facts
  module Windows
    module Networking
      class Interfaces
        FACT_NAME = 'networking.interfaces'

        def call_the_resolver
          fact_value = Facter::Resolvers::Windows::Networking.resolve(:interfaces)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
