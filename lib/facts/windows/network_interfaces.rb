# frozen_string_literal: true

module Facter
  module Windows
    class NetworkInterfaces
      FACT_NAME = 'network_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << ResolvedFact.new("network_#{interface_name}", info[:network], :legacy) if info[:network]
        end

        arr
      end
    end
  end
end
