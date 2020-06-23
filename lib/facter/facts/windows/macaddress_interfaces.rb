# frozen_string_literal: true

module Facts
  module Windows
    class MacaddressInterfaces
      FACT_NAME = 'macaddress_.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("macaddress_#{interface_name}", info[:mac], :legacy) if info[:mac]
        end

        arr
      end
    end
  end
end
