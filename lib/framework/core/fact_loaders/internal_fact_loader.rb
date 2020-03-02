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

      os_descendents = OsDetector.instance.hierarchy
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
        fact_name = class_name::FACT_NAME

        load_fact(fact_name, class_name)
        next unless class_name.const_defined?('ALIASES')

        [*class_name::ALIASES].each { |fact_alias| load_fact(fact_alias, class_name) }
      end
    end

    def load_fact(fact_name, klass)
      loaded_fact = LoadedFact.new(fact_name, klass)
      @facts << loaded_fact
    end
  end
end
