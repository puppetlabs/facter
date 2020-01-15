# frozen_string_literal: true

module Facter
  module Windows
    class MtuInterfaces
      FACT_NAME = 'mtu_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces.each do |interface_name, info|
          arr << ResolvedFact.new("mtu_#{interface_name}", info[:mtu], :legacy) if info[:mtu]
        end

        arr
      end
    end
  end
end
