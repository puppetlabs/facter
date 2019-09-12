# frozen_string_literal: true

module Facter
  module Macosx
    class NetworkIP
      FACT_NAME = 'networking.ip'

      def call_the_resolver
        ResolvedFact.new(FACT_NAME, 'l92.l68.O.1')
      end
    end
  end
end
