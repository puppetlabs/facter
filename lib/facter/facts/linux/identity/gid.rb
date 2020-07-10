# frozen_string_literal: true

module Facts
  module Linux
    module Identity
      class Gid
        FACT_NAME = 'identity.gid'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:gid)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
