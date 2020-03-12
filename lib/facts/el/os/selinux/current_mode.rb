# frozen_string_literal: true

module Facts
  module El
    module Os
      module Selinux
        class CurrentMode
          FACT_NAME = 'os.selinux.current_mode'
          ALIASES = 'selinux_current_mode'

          def call_the_resolver
            fact_value = Facter::Resolvers::SELinux.resolve(:current_mode)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
