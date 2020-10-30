# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Ipaddress < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_ipaddress(fact_name) }
          end

          def read_ipaddress(fact_name)
            ip = nil
            primary_interface = read_primary_interface
            unless primary_interface.nil?
              output = Facter::Core::Execution.execute("ifconfig #{primary_interface}", logger: log)
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
            output = Facter::Core::Execution.execute('route -n get default | grep interface', logger: log)
            output.strip =~ /interface:\s(\S+)/ ? Regexp.last_match(1) : nil
          end
        end
      end
    end
  end
end
