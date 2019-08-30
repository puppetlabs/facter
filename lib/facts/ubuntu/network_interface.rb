# frozen_string_literal: true

module Facter
  module Ubuntu
    class NetworkInterface
      FACT_NAME = 'networking.interface'

      def call_the_resolver(filter_criteria)
        @log.debug(filter_criteria)
        Fact.new(FACT_NAME, 'l0')
      end
    end
  end
end
