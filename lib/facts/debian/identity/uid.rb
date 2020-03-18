# frozen_string_literal: true

module Facts
  module Debian
    module Identity
      class Uid
        FACT_NAME = 'identity.uid'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:uid)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
