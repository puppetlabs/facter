# frozen_string_literal: true

module Facts
  module Freebsd
    module Identity
      class Privileged
        FACT_NAME = 'identity.privileged'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:privileged)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
