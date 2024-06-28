# frozen_string_literal: true

module Facter
  module Resolvers
    class DMISystemEnclosure < BaseResolver
      @log = Facter::Log.new(self)
      init_resolver

      class << self
        # ChassisType

        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { read_facts(fact_name) }
        end

        def read_facts(fact_name)
          win = Facter::Util::Windows::Win32Ole.new
          systemenclosure = win.return_first('SELECT ChassisTypes FROM Win32_SystemEnclosure')
          unless systemenclosure
            @log.debug 'WMI query returned no results for Win32_SystemEnclosure with values ChassisTypes.'
            return
          end

          build_fact_list(systemenclosure)

          # ChassisTypes is an Array on Windows - Convert the first one to a name
          chassis_to_name(@fact_list[fact_name][0]) if fact_name == :chassis_type

          @fact_list[fact_name]
        end

        def build_fact_list(systemenclosure)
          @fact_list[:chassis_type] = systemenclosure.ChassisTypes
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
