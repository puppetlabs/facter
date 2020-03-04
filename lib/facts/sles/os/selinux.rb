# frozen_string_literal: true

module Facts
  module Sles
    module Os
      class Selinux
        FACT_NAME = 'os.selinux'

        def call_the_resolver
          selinux = Facter::Resolvers::SELinux.resolve(:enabled)

          Facter::ResolvedFact.new(FACT_NAME, build_fact_list(selinux))
        end

        def build_fact_list(selinux)
          {
            enabled: selinux
          }
        end
      end
    end
  end
end
