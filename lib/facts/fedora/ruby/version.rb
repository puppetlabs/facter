# frozen_string_literal: true

module Facter
  module Fedora
    class RubyVersion
      FACT_NAME = 'ruby.version'

      def call_the_resolver
        fact_value = Resolvers::Ruby.resolve(:version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
