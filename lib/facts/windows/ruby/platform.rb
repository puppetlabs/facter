# frozen_string_literal: true

module Facter
  module Windows
    class RubyPlatform
      FACT_NAME = 'ruby.platform'
      ALIASES = 'rubyplatform'

      def call_the_resolver
        fact_value = Resolvers::Ruby.resolve(:platform)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end
