# frozen_string_literal: true

module Facter
  module Macosx
    class OsRelease
      FACT_NAME = 'os.release'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @args = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver!
        fact_value = UnameResolver.resolve(:release)
        release_strings = fact_value.split('.')
        Fact.new(FACT_NAME,
                 full: fact_value,
                 major: release_strings[0],
                 minor: release_strings[1])
      end
    end
  end
end
