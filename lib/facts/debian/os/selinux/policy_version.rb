# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Selinux
        class PolicyVersion
          FACT_NAME = 'os.selinux.policy_version'
          ALIASES = 'selinux_policyversion'

          def call_the_resolver
            fact_value = Facter::Resolvers::SELinux.resolve(:policy_version)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
