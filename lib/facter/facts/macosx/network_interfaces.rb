# frozen_string_literal: true

module Facts
  module Macosx
    class NetworkInterfaces
      FACT_NAME = 'network_.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("network_#{interface_name}", info[:network], :legacy) if info[:network]
        end

        arr
      end
    end
  end
end
