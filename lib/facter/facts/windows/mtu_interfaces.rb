# frozen_string_literal: true

module Facts
  module Windows
    class MtuInterfaces
      FACT_NAME = 'mtu_.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("mtu_#{interface_name}", info[:mtu], :legacy) if info[:mtu]
        end

        arr
      end
    end
  end
end
