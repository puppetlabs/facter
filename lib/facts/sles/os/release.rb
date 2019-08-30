# frozen_string_literal: true

module Facter
  module Sles
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        version = OsReleaseResolver.resolve('VERSION')

        Fact.new(FACT_NAME, build_fact_list(version))
      end

      def build_fact_list(version)
        {
          full: "#{version}.0",
          major: version,
          minor: 0
        }
      end
    end
  end
end
