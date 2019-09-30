# frozen_string_literal: true

module Facter
  module Debian
    class OsLsbRelease
      FACT_NAME = 'os.distro'

      def call_the_resolver
        distro = {
          'codename' => resolver_lsb(:codename),
          'description' => resolver_lsb(:description),
          'id' => resolver_lsb(:distributor_id),
          'release' => {
            'full' => resolver_version(:full),
            'major' => resolver_version(:major),
            'minor' => resolver_version(:minor)
          }
        }

        ResolvedFact.new(FACT_NAME, distro)
      end

      def resolver_lsb(key)
        Resolvers::LsbRelease.resolve(key)
      end

      def resolver_version(key)
        Resolvers::DebianVersion.resolve(key)
      end
    end
  end
end
