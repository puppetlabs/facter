# frozen_string_literal: true

module Facter
  module Opensuse
    class OsLsbRelease
      FACT_NAME = 'os.lsb'

      def call_the_resolver
        lsb = {
          'distcodename' => resolver('Codename'),
          'distid' => resolver('Distributor ID'),
          'distdescription' => resolver('Description'),
          'distrelease' => resolver('Release'),
          'majdistrelease' => resolver('Release')
        }

        Fact.new(FACT_NAME, lsb)
      end

      def resolver(key)
        LsbReleaseResolver.resolve(key)
      end
    end
  end
end
