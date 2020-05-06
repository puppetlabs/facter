# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Primary
        FACT_NAME = 'networking.primary'

        def call_the_resolver
          fact_value = Facter::Resolvers::NetworkingLinux.resolve(:primary_interface)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
