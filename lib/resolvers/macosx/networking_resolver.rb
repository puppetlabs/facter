# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class Ipaddress < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            get_primary_interface
            get_ip
            get_dhcp
            get_interfaces_data
            @fact_list[fact_name]
          end

          def get_primary_interface
            result = Facter::Core::Execution.execute('route -n get default', logger: log)

            @fact_list[:primary] = result.match(/(interface:)\K.+/)&.to_s&.strip
          end

          def get_ip
            unless @fact_list[:primary].nil?
              @fact_list[:ip] = Facter::Core::Execution.execute("ipconfig getifaddr #{@fact_list[:primary]}",
                                                                logger: log)
                .strip
            end
          end

          def get_dhcp
            result = Facter::Core::Execution.execute("ipconfig getpacket #{@fact_list[:primary]}", logger: log)

            @fact_list[:dhcp] = $1.strip if result =~ /server_identifier \(ip\):\s(.+)/
          end

          def get_interfaces_data
            command_response = Facter::Core::Execution.execute('ifconfig -a', logger: log)
            clean_up_interfaces_response(command_response)

            parse_interfaces_response(command_response)
          end

          def clean_up_interfaces_response(response)
            # convert ip ranges into single ip. eg. 10.16.132.213 -->  10.16.132.213 is converted to 10.16.132.213
            response.gsub!(/(\d+(\.\d+)*)\s+-->\s+\d+(\.\d+)*/, '\\1')
          end

          def parse_interfaces_response(response)
            properties_hash = {}
            data_hash = Hash[*response.split(/^([A-Za-z0-9_]+): /)[1..-1]]
            data_hash.each do |interface, properties|
              values = {}

              values['mtu'] = $1.to_i if properties =~ /mtu (\d+)/
              values['mac'] = $1 if properties =~ /ether (\S+)/

              ip = extract_values(properties, /inet (\S+)/)
              mask = extract_values(properties, /netmask (\S+)/).map { |val| val.hex.to_s(2).count('1') }

              ip6 = extract_values(properties, /inet6 (\S+)/).map { |val| val.gsub(/%.+/, '') }
              mask6 = extract_values(properties, /prefixlen (\S+)/)

              values['bindings'] = create_bindings(ip, mask) unless ip.empty?
              values['bindings6'] = create_bindings(ip6, mask6) unless ip6.empty?

              properties_hash[interface] = values
            end
            @fact_list[:interfaces] = properties_hash unless properties_hash.empty?
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
            [ips, masks].transpose.each do |ip, mask|
              bindings << Facter::Networking.build_binding(ip, mask)
            end
            bindings
          end
        end
      end
    end
  end
end
