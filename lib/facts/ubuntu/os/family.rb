# frozen_string_literal: true

module Facter
  module Ubuntu
    class OsFamily
      FACT_NAME = 'os.family'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @args = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact_value = UnameResolver.resolve(:family)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
