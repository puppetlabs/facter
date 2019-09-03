# frozen_string_literal: true

module Facter
  module Scientific
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        release = {
          'release' => {
            'full' => DebianVersionResolver.resolve(:full),
            'major' => DebianVersionResolver.resolve(:major),
            'minor' => DebianVersionResolver.resolve(:minor)
          }
        }

        Fact.new(FACT_NAME, release)
      end
    end
  end
end
