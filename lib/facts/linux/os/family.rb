# frozen_string_literal: true

module Facter
  module Linux
    class OsFamily
      FACT_NAME = 'os.family'
      @aliases = []

      def initialize(*args)
        @args = args
        puts 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact_value = OsResolver.resolve(:family)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
