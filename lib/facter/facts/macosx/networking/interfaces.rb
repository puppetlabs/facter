# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Interfaces
        FACT_NAME = 'networking.interfaces'

        def call_the_resolver
          interfaces = Facter::Resolvers::Networking.resolve(:interfaces)

          Facter::ResolvedFact.new(FACT_NAME, interfaces)
        end
      end
    end
  end
end
