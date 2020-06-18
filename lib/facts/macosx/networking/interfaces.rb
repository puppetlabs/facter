# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Interfaces
        FACT_NAME = 'networking.interfaces'

        def call_the_resolver
          interfaces = Facter::Resolvers::Macosx::Networking.resolve(:interfaces)
          dhcp = Facter::Resolvers::Macosx::Networking.resolve(:dhcp)
          primary = Facter::Resolvers::Macosx::Networking.resolve(:primary_interface)

          if interfaces
            interfaces[primary][:dhcp] = dhcp if interfaces[primary]
            expand_bindings(interfaces)
          end

          Facter::ResolvedFact.new(FACT_NAME, interfaces)
        end

        def expand_bindings(interfaces)
          interfaces.each_value do |values|
            expand_binding(values, values[:bindings]) if values[:bindings]
            expand_binding(values, values[:bindings6], false) if values[:bindings6]
          end
        end

        private

        def expand_binding(values, bindings, ipv4_type = true)
          binding = ::Resolvers::Utils::Networking.find_valid_binding(bindings)
          ip_protocol_type = ipv4_type ? '' : '6'

          values["ip#{ip_protocol_type}".to_sym] = binding[:address]
          values["netmask#{ip_protocol_type}".to_sym] = binding[:netmask]
          values["network#{ip_protocol_type}".to_sym] = binding[:network]
        end
      end
    end
  end
end
