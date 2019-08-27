# frozen_string_literal: true

module Facter
  module Macosx
    class NetworkInterface
      FACT_NAME = 'ipaddress_.*'
      @aliases = []

      def initialize(*args)
        @log = Log.new
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver
        [Fact.new('ipaddress_ens160', 'l0'), Fact.new('ipaddress_2', 'l0')]
      end
    end
  end
end
