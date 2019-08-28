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

      def call_the_resolver(filter_criteria)
        # resolve for ipaddress_filter_criteria
        return Fact.new('ipaddress_ens160', 'l0') if filter_criteria == 'ens160'
        return Fact.new('ipaddress_2', 'l2') if filter_criteria == '2'

        [Fact.new('ipaddress_ens160', 'l0'), Fact.new('ipaddress_2', 'l2')]
      end
    end
  end
end
