# frozen_string_literal: true

module Facts
  module Sles
    module Os
      module Distro
        class Id
          FACT_NAME = 'os.distro.id'

          def call_the_resolver
            fact_value = if Facter::Resolvers::OsRelease.resolve(:version_id).start_with?('12')
                           'SUSE LINUX'
                         else
                           'SUSE'
                         end
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end
