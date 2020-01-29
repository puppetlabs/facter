# frozen_string_literal: true

module Facter
  module Windows
    class MacaddressInterfaces
      FACT_NAME = 'macaddress_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << ResolvedFact.new("macaddress_#{interface_name}", info[:mac], :legacy) if info[:mac]
        end

        arr
      end
    end
  end
end
