# frozen_string_literal: true

module Facts
  module Aix
    module Networking
      class Interfaces
        FACT_NAME = 'networking.interfaces'

        def call_the_resolver
          fact_value = Facter::Resolvers::Aix::Networking.resolve(:interfaces)
          fact_value = fact_value&.any? ? fact_value : nil

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
