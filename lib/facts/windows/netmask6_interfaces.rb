# frozen_string_literal: true

module Facts
  module Windows
    class Netmask6Interfaces
      FACT_NAME = 'netmask6_.*'

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("netmask6_#{interface_name}", info[:netmask6], :legacy) if info[:netmask6]
        end

        arr
      end
    end
  end
end
