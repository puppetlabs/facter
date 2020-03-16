# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Selinux
        class ConfigMode
          FACT_NAME = 'os.selinux.config_mode'
          ALIASES = 'selinux_config_mode'

          def call_the_resolver
            fact_value = Facter::Resolvers::SELinux.resolve(:config_mode)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
