# frozen_string_literal: true

module Facts
  module Debian
    module Identity
      class User
        FACT_NAME = 'identity.user'
        ALIASES = 'id'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:user)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
