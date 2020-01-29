# frozen_string_literal: true

module Facter
  module Windows
    class Ipaddress6Interfaces
      FACT_NAME = 'ipaddress6_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << ResolvedFact.new("ipaddress6_#{interface_name}", info[:ip6], :legacy) if info[:ip6]
        end

        arr
      end
    end
  end
end
