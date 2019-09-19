# frozen_string_literal: true

module Facter
  module Ubuntu
    class OsLsbRelease
      FACT_NAME = 'os.distro'

      def call_the_resolver
        versions = resolver('Release').split('.')
        distro = {
          'codename' => resolver('Codename'),
          'description' => resolver('Description'),
          'id' => resolver('Distributor ID'),
          'release' => {
            'full' => resolver('Release'),
            'major' => versions[0],
            'minor' => versions[1]
          }
        }

        ResolvedFact.new(FACT_NAME, distro)
      end

      def resolver(key)
        Resolvers::LsbReleaseResolver.resolve(key)
      end
    end
  end
end
