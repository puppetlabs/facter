# frozen_string_literal: true

module Facter
  module Rhel
    class NetworkIP
      FACT_NAME = 'networking.ip'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @filter_tokens = args
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver
        Fact.new(FACT_NAME, 'l92.l68.O.l')
      end
    end
  end
end
