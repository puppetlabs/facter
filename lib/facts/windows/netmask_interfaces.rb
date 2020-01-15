# frozen_string_literal: true

module Facter
  module Windows
    class NetmaskInterfaces
      FACT_NAME = 'netmask_.*'

      def call_the_resolver
        arr = []
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces.each do |interface_name, info|
          arr << ResolvedFact.new("netmask_#{interface_name}", info[:netmask], :legacy) if info[:netmask]
        end

        arr
      end
    end
  end
end
