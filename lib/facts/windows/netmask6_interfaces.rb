# frozen_string_literal: true

module Facter
  module Windows
    class Netmask6Interfaces
      FACT_NAME = 'netmask6_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << ResolvedFact.new("netmask6_#{interface_name}", info[:netmask6], :legacy) if info[:netmask6]
        end

        arr
      end
    end
  end
end
