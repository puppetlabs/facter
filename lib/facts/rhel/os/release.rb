# frozen_string_literal: true

module Facter
  module Rhel
    class OsRelease
      FACT_NAME = 'os.release'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @filter_tokens = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver
        fact_value = OsReleaseResolver.resolve('VERSION_ID')

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end
