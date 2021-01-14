# frozen_string_literal: true

module Facter
  module Util
    module Linux
      class RoutingTable
        class << self
          ROUTE_TYPES = %w[anycast
                           unicast
                           broadcast
                           local
                           nat
                           unreachable
                           prohibit
                           blackhole
                           throw].freeze

          def read_routing_table(logger)
            ipv4_output = Facter::Core::Execution.execute('ip route show', logger: logger)
            ipv6_output = Facter::Core::Execution.execute('ip -6 route show', logger: logger)
            routes4 = parse_routes(ipv4_output, true)
            routes6 = parse_routes(ipv6_output, false)
            [routes4, routes6]
          end

          private

          def parse_routes(output, ipv4_type)
            routes = []
            output.each_line do |line|
              parts = line.split(' ').compact
              next if parts.include?('linkdown')

              delete_invalid_route_type(parts)
              next if !ipv4_type && !parts[0].include?(':')

              route = construct_route(parts)
              routes << route unless route[:ip].nil?
            end
            routes.uniq
          end

          def delete_invalid_route_type(parts)
            route_type = parts[0]
            parts.delete_at(0) if ROUTE_TYPES.include?(route_type)
          end

          def construct_route(parts)
            route = {}
            dev_index = parts.find_index { |elem| elem == 'dev' }
            src_index = parts.find_index { |elem| elem == 'src' }
            route[:interface] = parts[dev_index + 1] if dev_index
            route[:ip] = parts[src_index + 1] if src_index
            route
          end
        end
      end
    end
  end
end
