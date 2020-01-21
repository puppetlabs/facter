# frozen_string_literal: true

module Facter
  module Sles
    class RubyVersion
      FACT_NAME = 'ruby.version'
      ALIASES = 'rubyversion'

      def call_the_resolver
        fact_value = Resolvers::Ruby.resolve(:version)
        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
