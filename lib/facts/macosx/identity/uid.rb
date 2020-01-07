# frozen_string_literal: true

module Facter
  module Macosx
    class IdentityUid
      FACT_NAME = 'identity.uid'

      def call_the_resolver
        fact_value = Facter::Resolvers::PosxIdentity.resolve(:uid)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
