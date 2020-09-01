# frozen_string_literal: true

module Facter
  class ClassDiscoverer
    include Singleton

    def initialize
      @log = Log.new(self)
    end

    def discover_classes(operating_system)
      os_module_name = Module.const_get("Facts::#{operating_system}")

      # select only classes
      find_nested_classes(os_module_name, discovered_classes = [])
      discovered_classes
    rescue NameError
      @log.debug("There is no module named #{operating_system}")
      []
    end

    def find_nested_classes(mod, discovered_classes)
      mod.constants.each do |constant_name|
        if mod.const_get(constant_name).instance_of? Class
          discovered_classes << mod.const_get(constant_name)
        elsif mod.const_get(constant_name).instance_of? Module
          find_nested_classes(Module.const_get("#{mod.name}::#{constant_name}"), discovered_classes)
        end
      end
    end
  end
end
