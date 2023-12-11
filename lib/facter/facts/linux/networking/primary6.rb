# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Primary6
        FACT_NAME = 'networking.primary6'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Networking.resolve(:primary6_interface)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
