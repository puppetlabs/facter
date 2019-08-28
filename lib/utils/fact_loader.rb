# frozen_string_literal: true

module Facter
  class FactLoader
    # Loads all the facts for the operating system Facter is running on.
    # Facts are dynamically loaded from facts/#{operating_system}/*.rb
    # Returns a hash containing fact name and fact classes
    # e.g.
    #
    # {
    #     "networking.interface" => Facter::Linux::NetworkInterface,
    #     "networking.ip" => Facter::Linux::NetworkIP
    # }
    def self.load(operating_system)
      loaded_facts = {}
      os = operating_system.capitalize
      os_module_name = Module.const_get("Facter::#{os}")

      # select only classes
      classes = os_module_name.constants.select { |c| os_module_name.const_get(c).is_a? Class }

      classes.each do |class_name|
        klass = Class.const_get("Facter::#{os}::" + class_name.to_s)
        # fact_name = klass::FACT_NAME
        fact_name = klass::FACT_NAME
        loaded_facts.merge!(fact_name => klass)
      end

      loaded_facts
    end
  end
end
