# frozen_string_literal: true

module Facts
  module Macosx
    module Os
      module Macosx
        class Version
          FACT_NAME = 'os.macosx.version'

          def call_the_resolver
            fact_value = Facter::Resolvers::SwVers.resolve(:productversion)
            versions = fact_value.split('.')
            ver = { 'full' => fact_value, 'major' => "#{versions[0]}.#{versions[1]}", 'minor' => versions[-1] }

            Facter::ResolvedFact.new(FACT_NAME, ver)
          end
        end
      end
    end
  end
end
