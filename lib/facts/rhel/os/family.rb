# frozen_string_literal: true

module Facter
  module Rhel
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        fact_value = OsReleaseResolver.resolve('ID_LIKE')

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
