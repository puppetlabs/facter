# frozen_string_literal: true

module Facter
  class ClassDiscoverer
    include Singleton

    def discover_classes(operating_system)
      os_module_name = Module.const_get("Facter::#{operating_system}")

      # select only classes
      os_module_name.constants.select { |c| os_module_name.const_get(c).is_a? Class }
    end
  end
end
