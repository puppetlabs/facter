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
            get_primary_and_dhcp
            get_ip
            interfaces = get_interfaces_data
            @fact_list[fact_name]
          end

          def get_ip
            unless @fact_list[:primary].nil?
              @fact_list[:ip] = Facter::Core::Execution.execute("ipconfig getifaddr #{@fact_list[:primary]}",
                                                                logger: log)
                .strip
            end
          end

          def get_primary_and_dhcp
            result = Facter::Core::Execution.execute('route -n get default', logger: log)
            @fact_list[:primary] = result.match(/(interface:)\K.+/)&.to_s&.strip

            #dhcp nu este bun trebuie din comanda cu packet pt en0
            @fact_list[:dhcp] = result.match(/(gateway:)\K.+/)&.to_s&.strip
          end

          def get_interfaces_data
            command_response = Facter::Core::Execution.execute('ifconfig -a', logger: log)

            clean_up_interfaces_response(command_response)

            extract_info(command_response)
          end


          def clean_up_interfaces_response(response)
            # convert ip ranges into single ip eg. 10.16.132.213 -->  10.16.132.213 is converted to 10.16.132.213
            response.gsub!(/(\d+(\.\d+)*)\s+-->\s+\d+(\.\d+)*/, '\\1')
          end

          def extract_info(response)
            properties_hash = {}
            data_hash = Hash[*response.split(/^([A-Za-z0-9_]+): /)[1..-1]]
            data_hash.each do |interface, properties|
              values = {}
              ip, ip6, mask, mask6 = Array.new(4){ [] }
              values['mtu'] = $1.to_i if properties =~ /mtu (\d+)/
              values['mac'] = $1 if properties =~ /ether (\S+)/
              properties.scan(/inet6 (\S+)/).flatten.each do |val|
                ip6 << val.gsub(/%.+/, '')
              end
              properties.scan(/inet (\S+)/).flatten.each do |val|
                ip << val
              end
              properties.scan(/netmask (\S+)/).flatten.each do |val|
                mask << val.hex.to_s(2).count('1')
              end
              properties.scan(/prefixlen (\S+)/).flatten.each do |val|
                mask6 << val
              end
                values['bindings'] = [] unless ip.empty?
                values['bindings6'] = [] unless ip6.empty?
              [ip, mask].transpose.each do |ip, mask|
                values['bindings'] << build_binding(ip, mask)
              end
              [ip6, mask6].transpose.each do |ip, mask|
                values['bindings6'] << build_binding(ip, mask)
              end
              properties_hash[interface] = values
            end
            require 'pp'
            pp properties_hash
          end

          def build_binding(addr, mask_length)
            require 'ipaddr'

            addr = addr.gsub(/-->.+/, '') if addr.include?('-->')
            ip = IPAddr.new(addr)
            mask_helper = ip.ipv6? ? 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' : '255.255.255.255'
            mask = IPAddr.new(mask_helper).mask(mask_length)

            { address: addr, netmask: mask.to_s, network: ip.mask(mask_length).to_s }
          end
        end
      end
    end
  end
end
