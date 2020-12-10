# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      module Networking
        module PrimaryInterface
          @log ||= Log.new(self)

          class << self
            ROUTE_TABLE_MAPPING = {
              'Iface' => 0,
              'Destination' => 1,
              'Gateway' => 2,
              'Flags' => 3,
              'RefCnt' => 4,
              'Use' => 5,
              'Metric' => 6,
              'Mask' => 7,
              'MTU' => 8,
              'Window' => 9,
              'IRTT' => 10
            }.freeze

            def read_from_route
              return if Facter::Core::Execution.which('route').nil?

              result = Facter::Core::Execution.execute('route -n get default', logger: @log)

              result.match(/interface: (.+)/)&.captures&.first
            end

            def read_from_proc_route
              content = Facter::Util::FileHelper.safe_read('/proc/net/route', '')

              content.each_line.with_index do |line, index|
                next if index.zero?

                route = line.strip.split("\t")
                if route.count > 7 &&
                   route[ROUTE_TABLE_MAPPING['Destination']] == '00000000' &&
                   route[ROUTE_TABLE_MAPPING['Mask']] == '00000000'
                  return route[ROUTE_TABLE_MAPPING['Iface']]
                end
              end
              nil
            end

            def read_from_ip_route
              return if Facter::Core::Execution.which('ip').nil?

              output = Facter::Core::Execution.execute('ip route show default', logger: @log)
              primary_interface = nil
              output.each_line do |line|
                primary_interface = line.strip.split(' ')[4] if line.start_with?('default')
              end

              primary_interface
            end

            def find_in_interfaces(interfaces)
              interfaces.each do |iface_name, interface|
                interface[:bindings]&.each do |binding|
                  return iface_name unless Facter::Util::Resolvers::Networking.ignored_ip_address(binding[:address])
                end

                interface[:bindings6]&.each do |binding|
                  return iface_name unless Facter::Util::Resolvers::Networking.ignored_ip_address(binding[:address])
                end
              end

              nil
            end
          end
        end
      end
    end
  end
end
