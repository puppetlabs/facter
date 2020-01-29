# frozen_string_literal: true

module Facter
  module Windows
    class DhcpServers
      FACT_NAME = 'dhcp_servers'

      def call_the_resolver
        fact_value = construct_addresses_hash
        ResolvedFact.new(FACT_NAME, fact_value.empty? ? nil : fact_value, :legacy)
      end

      private

      def construct_addresses_hash
        servers = { system: Resolvers::Networking.resolve(:dhcp) }
        interfaces = Resolvers::Networking.resolve(:interfaces)
        interfaces&.each { |interface_name, info| servers[interface_name] = info[:dhcp] if info[:dhcp] }
        servers
      end
    end
  end
end
