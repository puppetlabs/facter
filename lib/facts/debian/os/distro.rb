# frozen_string_literal: true

module Facts
  module Debian
    module Os
      class Distro
        FACT_NAME = 'os.distro'

        def call_the_resolver
          versions = resolver(:release).split('.')
          distro = {
            'codename' => resolver(:codename),
            'description' => resolver(:description),
            'id' => resolver(:distributor_id),
            'release' => {
              'full' => resolver(:release),
              'major' => versions[0],
              'minor' => versions[1]
            }
          }

          Facter::ResolvedFact.new(FACT_NAME, distro)
        end

        def resolver(key)
          Facter::Resolvers::LsbRelease.resolve(key)
        end
      end
    end
  end
end
