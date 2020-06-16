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
            v4_binding(values) if values[:bindings]
            v6_binding(values) if values[:bindings6]
          end
        end

        private

        def v6_binding(values)
          values[:ip6] = values[:bindings6][0][:address]
          values[:netmask6] = values[:bindings6][0][:netmask]
          values[:network6] = values[:bindings6][0][:network]
        end

        def v4_binding(values)
          values[:ip] = values[:bindings][0][:address]
          values[:netmask] = values[:bindings][0][:netmask]
          values[:network] = values[:bindings][0][:network]
        end
      end
    end
  end
end
