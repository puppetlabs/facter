# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Dmi < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          SMBIOS_PARAMS = {
            'SMB_TYPE_BIOS' => {
              bios_version: 'Version String: (.+)',
              bios_vendor: 'Vendor: (.+)',
              bios_release_date: 'Release Date: (.+)'
            },
            'SMB_TYPE_SYSTEM' => {
              manufacturer: 'Manufacturer: (.+)',
              product_name: 'Product: (.+)',
              serial_number: 'Serial Number: (.+)',
              product_uuid: 'UUID: (.+)'
            },
            'SMB_TYPE_CHASSIS' => {
              chassis_asset_tag: 'Asset Tag: (.+)',
              chassis_type: '(?:Chassis )?Type: (.+)'
            }
          }.freeze

          def read_facts(fact_name)
            param = SMBIOS_PARAMS.find { |_key, hash| hash[fact_name] }
            return nil unless param

            output = exec_smbios(param[0])
            facts = param[1]
            return unless output

            facts.each do |name, regx|
              @fact_list[name] = output.match(/#{regx}/)&.captures&.first
            end

            @fact_list[fact_name]
          end

          def exec_smbios(args)
            return unless File.executable?('/usr/sbin/smbios')

            Facter::Core::Execution.execute("/usr/sbin/smbios -t #{args}", logger: log)
          end
        end
      end
    end
  end
end
