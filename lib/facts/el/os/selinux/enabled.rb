# frozen_string_literal: true

module Facts
  module El
    module Os
      module Selinux
        class Enabled
          FACT_NAME = 'os.selinux.enabled'
          ALIASES = 'selinux'

          def call_the_resolver
            selinux = Facter::Resolvers::SELinux.resolve(:enabled)

            [Facter::ResolvedFact.new(FACT_NAME, selinux),
             Facter::ResolvedFact.new(ALIASES, selinux, :legacy)]
          end
        end
      end
    end
  end
end
