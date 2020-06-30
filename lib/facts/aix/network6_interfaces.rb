# frozen_string_literal: true

module Facts
  module Aix
    class Network6Interfaces
      FACT_NAME = 'network6_.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Aix::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("network6_#{interface_name}", info[:network6], :legacy) if info[:network6]
        end

        arr
      end
    end
  end
end
