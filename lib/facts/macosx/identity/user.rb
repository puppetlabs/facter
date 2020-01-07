# frozen_string_literal: true

module Facter
  module Macosx
    class IdentityUser
      FACT_NAME = 'identity.user'

      def call_the_resolver
        fact_value = Facter::Resolvers::PosxIdentity.resolve(:user)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
