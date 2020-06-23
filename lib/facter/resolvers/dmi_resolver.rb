# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class DmiBios < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          # :bios_vendor
          # :bios_date
          # :bios_version
          # :board_vendor
          # :board_serial
          # :board_name
          # :chassis_asset_tag
          # :chassis_type
          # :sys_vendor
          # :product_serial
          # :product_name
          # :product_uuid

          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            files = %w[bios_date bios_vendor bios_version board_vendor board_name board_serial
                       chassis_asset_tag chassis_type sys_vendor product_name product_serial
                       product_uuid]
            return unless File.directory?('/sys/class/dmi')

            file_content = Util::FileHelper.safe_read("/sys/class/dmi/id/#{fact_name}", nil)
            if files.include?(fact_name.to_s) && file_content
              @fact_list[fact_name] = file_content.strip
              chassis_to_name(@fact_list[fact_name]) if fact_name == :chassis_type

            end
            @fact_list[fact_name]
          end

          def chassis_to_name(chassis_type)
            types = ['Other', nil, 'Desktop', 'Low Profile Desktop', 'Pizza Box', 'Mini Tower', 'Tower',
                     'Portable', 'Laptop', 'Notebook', 'Hand Held', 'Docking Station', 'All in One', 'Sub Notebook',
                     'Space-Saving', 'Lunch Box', 'Main System Chassis', 'Expansion Chassis', 'SubChassis',
                     'Bus Expansion Chassis', 'Peripheral Chassis', 'Storage Chassis', 'Rack Mount Chassis',
                     'Sealed-Case PC', 'Multi-system', 'CompactPCI', 'AdvancedTCA', 'Blade', 'Blade Enclosure',
                     'Tablet', 'Convertible', 'Detachable']
            @fact_list[:chassis_type] = types[chassis_type.to_i - 1]
          end
        end
      end
    end
  end
end
