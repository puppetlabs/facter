# frozen_string_literal: true

module Facter
  module Macosx
    class NetworkInterface
      FACT_NAME = 'networking.interface'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver
        Fact.new(FACT_NAME, 'l0')
      end
    end
  end
end
