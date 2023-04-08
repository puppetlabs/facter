# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Networking < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_netstat(fact_name) }
          end

          def read_netstat(fact_name)
            @fact_list[:interfaces] = {}
            output = Facter::Core::Execution.execute('netstat -rn', logger: log)
            output = output.each_line.select { |line| (line =~ /\s\s[0-9]+.[0-9]+.[0-9]+.[0-9]+|\s\s.*:[0-9a-f]+/) }
            @fact_list[:interfaces] = load_interfaces

            populate_with_mtu_and_mac!(@fact_list[:interfaces])
            get_primary_interface_info(output)
            Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
            @fact_list[fact_name]
          end

          def get_primary_interface_info(output)
            primary_interface_info = output.find { |line| line =~ /default/ }&.split(' ')
            @fact_list[:primary_interface] = primary_interface_info[5] if primary_interface_info
          end

          def build_bindings(name, ip, mask_length, is_ipv4)
            bind_to_add = is_ipv4 ? :bindings : :bindings6
            ip = ip.gsub(/%[0-9]$/, '') # remove mask information if it exists
            mask_length = mask_length.to_i - 1 unless is_ipv4
            @fact_list[:interfaces][name] ||= {}
            @fact_list[:interfaces][name][bind_to_add] ||= []
            @fact_list[:interfaces][name][bind_to_add] << Facter::Util::Resolvers::Networking
                                                          .build_binding(ip, mask_length)
          end

          def populate_with_mtu_and_mac!(interfaces)
            output = Facter::Core::Execution.execute('netstat -in', logger: log)
            output.each_line do |line|
              next if /Name\s/.match?(line)

              info = line.split("\s")
              interface_name = info[0]
              mac = info[3][/^([0-9a-f]{1,2}[\.:-]){5}([0-9a-f]{1,2})$/]
              interfaces[interface_name][:mtu] = info[1].to_i
              interfaces[interface_name][:mac] = format_mac_address(mac) if mac
            end
          end

          def format_mac_address(address)
            address.split('.').map { |e| format('%<mac_address>02s', mac_address: e) }.join(':').tr(' ', '0')
          end

          def load_interfaces
            require_relative 'ffi/ffi_helper'

            FfiHelper.read_interfaces
          end
        end
      end
    end
  end
end
