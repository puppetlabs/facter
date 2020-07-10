# frozen_string_literal: true

module Facts
  module Solaris
    module Identity
      class Group
        FACT_NAME = 'identity.group'
        ALIASES = 'gid'

        def call_the_resolver
          fact_value = Facter::Resolvers::PosxIdentity.resolve(:group)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
