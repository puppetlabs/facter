# frozen_string_literal: true

module Facter
  class InternalFactLoader
    attr_reader :facts

    def core_facts
      @facts.select { |fact| fact.type == :core }
    end

    def legacy_facts
      @facts.select { |fact| fact.type == :legacy }
    end

    def initialize
      @facts = []

      os_descendents = CurrentOs.instance.hierarchy
      load_all_oses(os_descendents)
    end

    private

    def load_all_oses(os_descendents)
      os_descendents.each do |os|
        load_for_os(os)
      end
    end

    def load_for_os(operating_system)
      # select only classes
      classes = ClassDiscoverer.instance.discover_classes(operating_system)

      classes.each do |class_name|
        klass = klass(operating_system, class_name)
        fact_name = klass::FACT_NAME

        load_fact(fact_name, klass)
      end
    end

    def klass(operating_system, class_name)
      Class.const_get("Facter::#{operating_system}::" + class_name.to_s)
    end

    def load_fact(fact_name, klass)
      loaded_fact = LoadedFact.new(fact_name, klass, fact_type(klass))
      @facts << loaded_fact
    end

    def fact_type(klass)
      return nil unless klass.const_defined?('FACT_TYPE')

      klass::FACT_TYPE
    end
  end
end
