# frozen_string_literal: true

module Facter
  module Macosx
    class IdentityGid
      FACT_NAME = 'identity.gid'

      def call_the_resolver
        fact_value = Facter::Resolvers::PosxIdentity.resolve(:gid)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
