# frozen_string_literal: true

module Facter
  module Windows
    class RubyVersion
      FACT_NAME = 'ruby.version'

      def call_the_resolver
        fact_value = Resolver::RubyResolver.resolve(:version)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
