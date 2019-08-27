# frozen_string_literal: true

module Facter
  module Macosx
    class OsName
      FACT_NAME = 'os.name'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @filter_tokens = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver
        fact_value = UnameResolver.resolve(:name)
        [Fact.new(FACT_NAME, fact_value)]
      end
    end
  end
end
