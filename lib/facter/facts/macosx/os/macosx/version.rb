# frozen_string_literal: true

module Facts
  module Macosx
    module Os
      module Macosx
        class Version
          FACT_NAME = 'os.macosx.version'
          ALIASES = %w[macosx_productversion macosx_productversion_major macosx_productversion_minor].freeze

          def call_the_resolver
            fact_value = Facter::Resolvers::SwVers.resolve(:productversion)
            versions = fact_value.split('.')
            ver = { 'full' => fact_value, 'major' => "#{versions[0]}.#{versions[1]}", 'minor' => versions[-1] }

            [Facter::ResolvedFact.new(FACT_NAME, ver),
             Facter::ResolvedFact.new(ALIASES[0], fact_value, :legacy),
             Facter::ResolvedFact.new(ALIASES[1], ver['major'], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], ver['minor'], :legacy)]
          end
        end
      end
    end
  end
end
