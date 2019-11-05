# frozen_string_literal: true

module Facter
  module Fedora
    class ProcessorsIsa
      FACT_NAME = 'processors.isa'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelrelease)

        ResolvedFact.new(FACT_NAME, get_isa(fact_value))
      end

      private

      def get_isa(fact_value)
        value_split = fact_value.split('.')

        value_split.last
      end
    end
  end
end
