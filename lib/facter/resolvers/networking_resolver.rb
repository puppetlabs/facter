# frozen_string_literal: true

module Facter
  module Resolvers
    class Networking < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_facts(fact_name) }
        end

        def read_facts(fact_name)
          primary_interface
          interfaces_data
          Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
          @fact_list[fact_name]
        end

        def primary_interface
          result = Facter::Core::Execution.execute('route -n get default', logger: log)

          @fact_list[:primary_interface] = result.match(/interface: (.+)/)&.captures&.first
        end

        def interfaces_data
          command_response = Facter::Core::Execution.execute('ifconfig -a', logger: log)

          clean_up_interfaces_response(command_response)
          parse_interfaces_response(command_response)
        end

        def clean_up_interfaces_response(response)
          # convert ip ranges into single ip. eg. 10.16.132.213 -->  10.16.132.213 is converted to 10.16.132.213
          response.gsub!(/(\d+(\.\d+)*)\s+-->\s+\d+(\.\d+)*/, '\\1')
        end

        def parse_interfaces_response(response)
          parsed_interfaces_data = {}
          interfaces_data = Hash[*response.split(/^([A-Za-z0-9_]+): /)[1..-1]]

          interfaces_data.each do |interface_name, raw_data|
            parsed_interface_data = {}

            extract_mtu(raw_data, parsed_interface_data)
            extract_mac(raw_data, parsed_interface_data)
            extract_dhcp(interface_name, raw_data, parsed_interface_data)
            extract_ip_data(raw_data, parsed_interface_data)

            parsed_interfaces_data[interface_name] = parsed_interface_data
          end
          @fact_list[:interfaces] = parsed_interfaces_data unless parsed_interfaces_data.empty?
        end

        def extract_mtu(raw_data, parsed_interface_data)
          mtu = raw_data.match(/mtu\s+(\d+)/)&.captures&.first&.to_i
          parsed_interface_data[:mtu] = mtu unless mtu.nil?
        end

        def extract_mac(raw_data, parsed_interface_data)
          mac = raw_data.match(/(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/)&.captures&.first
          parsed_interface_data[:mac] = mac unless mac.nil?
        end

        def extract_dhcp(interface_name, raw_data, parsed_interface_data)
          return unless raw_data =~ /status:\s+active/

          result = Facter::Core::Execution.execute("ipconfig getoption #{interface_name} " \
                                                     'server_identifier', logger: log)

          parsed_interface_data[:dhcp] = result.match(/^[\d.a-f:\s]+$/)&.to_s&.strip unless result.empty?
        end

        def extract_ip_data(raw_data, parsed_interface_data)
          ip = extract_values(raw_data, /inet (\S+)/)
          mask = extract_values(raw_data, /netmask (\S+)/).map { |val| val.hex.to_s(2).count('1') }

          ip6 = extract_values(raw_data, /inet6 (\S+)/).map { |val| val.gsub(/%.+/, '') }
          mask6 = extract_values(raw_data, /prefixlen (\S+)/)

          parsed_interface_data[:bindings] = create_bindings(ip, mask) unless ip.empty?
          parsed_interface_data[:bindings6] = create_bindings(ip6, mask6) unless ip6.empty?
        end

        def extract_values(data, regex)
          results = []
          data.scan(regex).flatten.each do |val|
            results << val
          end
          results
        end

        def create_bindings(ips, masks)
          bindings = []
          ips.zip(masks).each do |ip, mask|
            bindings << Facter::Util::Resolvers::Networking.build_binding(ip, mask)
          end
          bindings
        end
      end
    end
  end
end
