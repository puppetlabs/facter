# frozen_string_literal: true

module Facter
  module Aix
    class Path
      FACT_NAME = 'path'

      def call_the_resolver
        fact_value = Resolvers::Path.resolve(:path)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
