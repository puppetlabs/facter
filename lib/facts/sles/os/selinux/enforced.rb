# frozen_string_literal: true

module Facts
  module Sles
    module Os
      module Selinux
        class Enforced
          FACT_NAME = 'os.selinux.enforced'
          ALIASES = 'selinux_enforced'

          def call_the_resolver
            fact_value = Facter::Resolvers::SELinux.resolve(:enforced)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
