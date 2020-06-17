# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class Networking < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            primary_interface
            dhcp
            interfaces_data
            @fact_list[fact_name]
          end

          def primary_interface
            result = Facter::Core::Execution.execute('route -n get default', logger: log)

            @fact_list[:primary_interface] = result.match(/interface: (.+)/)&.captures&.first
          end

          def dhcp
            return if @fact_list[:primary_interface].nil?

            result = Facter::Core::Execution.execute("ipconfig getoption #{@fact_list[:primary_interface]} " \
                                                       'server_identifier', logger: log)

            @fact_list[:dhcp] = result.match(/^[\d.a-f:\s]+$/)&.to_s&.strip
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
            interfaces_data = Hash[*response.split(/^([A-Za-z0-9_]+): /)[1..-1]].sort
            interfaces_data.each do |interface, properties|
              values = {}

              extract_mtu(properties, values)
              extract_mac(properties, values)
              extract_ips(properties, values)

              parsed_interfaces_data[interface] = values
            end
            @fact_list[:interfaces] = parsed_interfaces_data unless parsed_interfaces_data.empty?
          end

          def extract_mtu(properties, values)
            mtu = properties.match(/mtu (\d+)/)&.captures&.first&.to_i
            values[:mtu] = mtu unless mtu.nil?
          end

          def extract_mac(properties, values)
            mac = properties.match(/ether (\S+)/)&.captures&.first
            values[:mac] = mac unless mac.nil?
          end

          def extract_ips(properties, values)
            ip = extract_values(properties, /inet (\S+)/)
            mask = extract_values(properties, /netmask (\S+)/).map { |val| val.hex.to_s(2).count('1') }

            ip6 = extract_values(properties, /inet6 (\S+)/).map { |val| val.gsub(/%.+/, '') }
            mask6 = extract_values(properties, /prefixlen (\S+)/)

            values[:bindings] = create_bindings(ip, mask) unless ip.empty?
            values[:bindings6] = create_bindings(ip6, mask6) unless ip6.empty?
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
              bindings << ::Resolvers::Utils::Networking.build_binding(ip, mask)
            end
            bindings
          end
        end
      end
    end
  end
end
