# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
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
              output, _status = Open3.capture2("ifconfig #{primary_interface}")
              output.each_line do |str|
                if str.strip =~ /inet\s(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}) .+/
                  @fact_list[:ip] = ip = Regexp.last_match(1)
                  break
                end
              end
            end
            @fact_list[fact_name]
          end

          def read_primary_interface
            output, _status = Open3.capture2('route -n get default | grep interface')
            output.strip =~ /interface:\s(\S+)/ ? Regexp.last_match(1) : nil
          end
        end
      end
    end
  end
end
