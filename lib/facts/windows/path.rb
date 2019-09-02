# frozen_string_literal: true

module Facter
  module Windows
    class Path
      FACT_NAME = 'path'

      def call_the_resolver
        fact_value = PathResolver.resolve(:path)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
