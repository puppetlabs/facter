# frozen_string_literal: true

module Facter
  module Ubuntu
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        fact_value = Resolver::LsbReleaseResolver.resolve('Release')
        versions = fact_value.split('.')
        release = {
          'release' => {
            'full' => fact_value,
            'major' => versions[0],
            'minor' => versions[1]
          }
        }

        ResolvedFact.new(FACT_NAME, release)
      end
    end
  end
end
