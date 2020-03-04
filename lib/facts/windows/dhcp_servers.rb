# frozen_string_literal: true

module Facts
  module Windows
    class DhcpServers
      FACT_NAME = 'dhcp_servers'

      def call_the_resolver
        fact_value = construct_addresses_hash
        Facter::ResolvedFact.new(FACT_NAME, fact_value.empty? ? nil : fact_value, :legacy)
      end

      private

      def construct_addresses_hash
        servers = { system: Facter::Resolvers::Networking.resolve(:dhcp) }
        interfaces = Facter::Resolvers::Networking.resolve(:interfaces)
        interfaces&.each { |interface_name, info| servers[interface_name] = info[:dhcp] if info[:dhcp] }
        servers
      end
    end
  end
end
