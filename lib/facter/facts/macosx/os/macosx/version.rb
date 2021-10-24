# frozen_string_literal: true

module Facts
  module Macosx
    module Os
      module Macosx
        class Version
          FACT_NAME = 'os.macosx.version'
          ALIASES = %w[macosx_productversion macosx_productversion_major macosx_productversion_minor
                       macosx_productversion_patch].freeze

          def call_the_resolver
            fact_value = Facter::Resolvers::SwVers.resolve(:productversion)
            ver = version_hash(fact_value)

            [Facter::ResolvedFact.new(FACT_NAME, ver),
             Facter::ResolvedFact.new(ALIASES[0], fact_value, :legacy),
             Facter::ResolvedFact.new(ALIASES[1], ver['major'], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], ver['minor'], :legacy),
             Facter::ResolvedFact.new(ALIASES[3], ver['patch'], :legacy)]
          end

          def version_hash(fact_value)
            versions = fact_value.split('.')
            if versions[0] == '10'
              { 'full' => fact_value, 'major' => "#{versions[0]}.#{versions[1]}", 'minor' => versions[-1] }
            else
              { 'full' => fact_value, 'major' => versions[0], 'minor' => versions.fetch(1, '0'),
                'patch' => versions.fetch(2, '0') }
            end
          end
        end
      end
    end
  end
end
