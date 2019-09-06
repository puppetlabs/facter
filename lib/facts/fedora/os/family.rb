# frozen_string_literal: true

module Facter
  module Fedora
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        Fact.new(FACT_NAME, 'RedHat')
      end
    end
  end
end
