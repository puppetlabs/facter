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
            version_value = Facter::Resolvers::SwVers.resolve(:productversion)
            extra_value = Facter::Resolvers::SwVers.resolve(:productversionextra)
            ver = version_hash(version_value, extra_value)

            [Facter::ResolvedFact.new(FACT_NAME, ver),
             Facter::ResolvedFact.new(ALIASES[0], version_value, :legacy),
             Facter::ResolvedFact.new(ALIASES[1], ver['major'], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], ver['minor'], :legacy),
             Facter::ResolvedFact.new(ALIASES[3], ver['patch'], :legacy)]
          end

          def version_hash(version_value, extra_value)
            versions = version_value.split('.')
            if versions[0] == '10'
              { 'full' => version_value, 'major' => "#{versions[0]}.#{versions[1]}", 'minor' => versions[-1] }
            elsif /11|12/.match?(versions[0]) || extra_value.nil?
              { 'full' => version_value, 'major' => versions[0], 'minor' => versions.fetch(1, '0'),
                'patch' => versions.fetch(2, '0') }
            else
              { 'full' => version_value, 'major' => versions[0], 'minor' => versions.fetch(1, '0'),
                'patch' => versions.fetch(2, '0'), 'extra' => extra_value }
            end
          end
        end
      end
    end
  end
end
