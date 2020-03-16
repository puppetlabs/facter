# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Selinux
        class ConfigPolicy
          FACT_NAME = 'os.selinux.config_policy'
          ALIASES = 'selinux_config_policy'

          def call_the_resolver
            fact_value = Facter::Resolvers::SELinux.resolve(:config_policy)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
