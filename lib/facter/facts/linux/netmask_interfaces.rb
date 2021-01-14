# frozen_string_literal: true

module Facts
  module Linux
    class NetmaskInterfaces
      FACT_NAME = 'netmask_.*'
      TYPE = :legacy

      def call_the_resolver
        arr = []
        interfaces = Facter::Resolvers::Linux::Networking.resolve(:interfaces)
        interfaces&.each do |interface_name, info|
          arr << Facter::ResolvedFact.new("netmask_#{interface_name}", info[:netmask], :legacy) if info[:netmask]
        end

        arr
      end
    end
  end
end
