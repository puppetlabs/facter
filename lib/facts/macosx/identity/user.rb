# frozen_string_literal: true

module Facts
  module Macosx
    module Identity
      class User
        FACT_NAME = 'identity.user'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:user)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
