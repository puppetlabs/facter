# frozen_string_literal: true

module Facts
  module El
    module Os
      class Selinux
        FACT_NAME = 'os.selinux'
        ALIASES = 'selinux'

        def call_the_resolver
          selinux = Facter::Resolvers::SELinux.resolve(:enabled)

          [Facter::ResolvedFact.new(FACT_NAME, enabled: selinux),
           Facter::ResolvedFact.new(ALIASES, selinux, :legacy)]
        end
      end
    end
  end
end
