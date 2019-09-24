# frozen_string_literal: true

module Facter
  module Windows
    class IdentityPrivileged
      FACT_NAME = 'identity.privileged'

      def call_the_resolver
        fact_value = Resolvers::Identity.resolve(:privileged)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
