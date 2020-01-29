# frozen_string_literal: true

module Facter
  module Windows
    class IpaddressInterfaces
      FACT_NAME = 'ipaddress_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << ResolvedFact.new("ipaddress_#{interface_name}", info[:ip], :legacy) if info[:ip]
        end

        arr
      end
    end
  end
end
