# frozen_string_literal: true

module Facter
  module Debian
    class RubyPlatform
      FACT_NAME = 'ruby.platform'

      def call_the_resolver
        fact_value = Resolvers::Ruby.resolve(:platform)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
