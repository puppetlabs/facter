# frozen_string_literal: true

module Facts
  module Macosx
    module Identity
      class Group
        FACT_NAME = 'identity.group'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:group)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end
