# frozen_string_literal: true

module Facts
  module Windows
    class Ipaddress6Interfaces
      FACT_NAME = 'ipaddress6_.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("ipaddress6_#{interface_name}", info[:ip6], :legacy) if info[:ip6]
        end

        arr
      end
    end
  end
end
