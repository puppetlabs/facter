# frozen_string_literal: true

module Facter
  module Rhel
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        version = OsReleaseResolver.resolve('VERSION_ID')

        Fact.new(FACT_NAME, build_fact_list(version))
      end

      def build_fact_list(version)
        versions = version.split('.')
        {
          full: version,
          major: versions[0],
          minor: versions[1]
        }
      end
    end
  end
end
