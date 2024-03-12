# frozen_string_literal: true

require_relative '../networking'

module Facter
  module Resolvers
    module Openbsd
      class Dhcp < Facter::Resolvers::Networking
        init_resolver
        class << self
          def extract_dhcp(interface_name, raw_data, parsed_interface_data)
            return unless raw_data.match?(/status:\s+active/)

            result = Facter::Core::Execution.execute("dhcpleasectl -l #{interface_name}", logger: log)
            parsed_interface_data[:dhcp] = extract_values(result, /\sdhcp server (\S+)/).first unless result.empty?
          end
        end
      end
    end
  end
end
