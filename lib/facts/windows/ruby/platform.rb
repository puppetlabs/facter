# frozen_string_literal: true

module Facter
  module Windows
    class RubyPlatform
      FACT_NAME = 'ruby.platform'

      def call_the_resolver
        fact_value = RubyResolver.resolve(:platform)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
