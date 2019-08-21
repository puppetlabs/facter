# frozen_string_literal: true

module Facter
  module Ubuntu
    class OsRelease
      FACT_NAME = 'os.release'
      @aliases = []

      def initialize(*args)
        @log = Lg.new
        @args = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact_value = UnameResolver.resolve(:release)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
