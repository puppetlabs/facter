# frozen_string_literal: true

module Facter
  module Fedora
    class RubySitedir
      FACT_NAME = 'ruby.sitedir'

      def call_the_resolver
        fact_value = Resolvers::Ruby.resolve(:sitedir)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
