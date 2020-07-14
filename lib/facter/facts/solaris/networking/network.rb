# frozen_string_literal: true

module Facts
  module Solaris
    module Networking
      class Network
        FACT_NAME = 'networking.network'
        ALIASES = 'network'

        def call_the_resolver
          fact_value = Facter::Resolvers::Solaris::Networking.resolve(:network)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
