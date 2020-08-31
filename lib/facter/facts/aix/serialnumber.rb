# frozen_string_literal: true

module Facts
  module Aix
    class Serialnumber
      FACT_NAME = 'serialnumber'
      TYPE = :legacy

      def call_the_resolver
        Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end

      private

      def fact_value
        Facter::Resolvers::Aix::Serialnumber.resolve(:serialnumber)
      end
    end
  end
end
