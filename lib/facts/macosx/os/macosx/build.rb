# frozen_string_literal: true

module Facts
  module Macosx
    module Os
      module Macosx
        class Build
          FACT_NAME = 'os.macosx.build'
          ALIASES = 'macosx_buildversion'

          def call_the_resolver
            fact_value = Facter::Resolvers::SwVers.resolve(:buildversion)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end
