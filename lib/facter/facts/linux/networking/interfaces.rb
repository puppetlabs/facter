# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Interfaces
        FACT_NAME = 'networking.interfaces'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Networking.resolve(:interfaces)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
