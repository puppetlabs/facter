# frozen_string_literal: true

module Facter
  module Ubuntu
    class NetworkInterface
      FACT_NAME = 'ipaddress_.*'
      FACT_TYPE = :legacy
      @aliases = []

      def initialize(*args)
        @log = Log.new(self)
        @log.debug 'Dispatching to resolve: ' + args.inspect
      end

      def call_the_resolver(filter_criteria)
        # resolve for ipaddress_filter_criteria
        return ResolvedFact.new('ipaddress_ens160', 'l0') if filter_criteria == 'ens160'
        return ResolvedFact.new('ipaddress_2', 'l2') if filter_criteria == '2'

        [ResolvedFact.new('ipaddress_ens160', 'l0'), ResolvedFact.new('ipaddress_2', 'l2')]
      end
    end
  end
end
