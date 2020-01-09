# frozen_string_literal: true

module Facter
  module Windows
    class RubySitedir
      FACT_NAME = 'ruby.sitedir'
      ALIASES = 'rubysitedir'

      def call_the_resolver
        fact_value = Resolvers::Ruby.resolve(:sitedir)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
