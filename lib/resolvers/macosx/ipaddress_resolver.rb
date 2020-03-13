# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class Ipaddress < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_ipaddress(fact_name) }
          end

          def read_ipaddress(fact_name)
            ip = nil
            primary_interface = read_primary_interface
            unless primary_interface.nil?
              output, _status = Open3.capture2("ipconfig getifaddr #{primary_interface}")
              ip = output.strip
            end
            @fact_list[:ip] = ip
            @fact_list[fact_name]
          end

          def read_primary_interface
            find_all_interfaces
            iface = nil
            output, _status = Open3.capture2('route -n get default')
            output.split(/^\S/).each do |str|
              iface = Regexp.last_match(1) if str.strip =~ /interface: (\S+)/
            end
            iface
          end

          def find_all_interfaces
            output, _status = Open3.capture2('ifconfig -a 2>/dev/null')
            output = output.scan(/^\S+/).collect { |i| i.sub(/:$/, '') }.uniq
            @fact_list[:interfaces] = output.collect { |iface| iface.gsub(/[^a-z0-9_]/i, '_') }.join(',')
          end
        end
      end
    end
  end
end
