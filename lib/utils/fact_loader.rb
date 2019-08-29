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
    def self.load(operating_system, load_legacy)
      loaded_facts = {}
      os = operating_system.capitalize

      # select only classes
      classes = get_all_classes_for_os(os)

      classes.each do |class_name|
        klass = Class.const_get("Facter::#{os}::" + class_name.to_s)

        if load_legacy
          # load all facts
          fact_name = klass::FACT_NAME
          loaded_facts.merge!(fact_name => klass)
        elsif !fact_legacy?(klass)
          # only non legacy facts
          fact_name = klass::FACT_NAME
          loaded_facts.merge!(fact_name => klass)
        end
      end

      loaded_facts
    end

    def self.get_all_classes_for_os(opperating_system)
      os_module_name = Module.const_get("Facter::#{opperating_system}")

      # select only classes
      os_module_name.constants.select { |c| os_module_name.const_get(c).is_a? Class }
    end

    def self.fact_legacy?(klass)
      klass.const_defined?('FACT_TYPE') && klass::FACT_TYPE.equal?(:legacy)
    end
  end
end
