# frozen_string_literal: true

module Facter
  module Util
    module Resolvers
      module Networking
        module Dhcp
          class << self
            def get(interface_name, log = nil)
              dhcpinfo_command = Facter::Core::Execution.which('dhcpinfo') || '/sbin/dhcpinfo'
              result = Facter::Core::Execution.execute("#{dhcpinfo_command} -i #{interface_name} ServerID", logger: log)

              result.chomp
            end
          end
        end
      end
    end
  end
end
