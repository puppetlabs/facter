# frozen_string_literal: true

module Facter
  class InternalFactLoader
    attr_reader :core_facts, :legacy_facts, :facts

    def initialize
      @core_facts = []
      @legacy_facts = []
      @facts = []

      @os = CurrentOs.instance.identifier.capitalize

      load
    end

    private

    def load
      # select only classes
      classes = ClassDiscoverer.instance.discover_classes(@os)

      classes.each do |class_name|
        klass = klass(class_name)
        fact_name = klass::FACT_NAME

        if legacy_fact?(klass)
          load_legacy_fact(fact_name, klass)
        else
          load_core_facts(fact_name, klass)
        end
      end

      all_facts
    end

    def all_facts
      @facts = @legacy_facts.concat(@core_facts)
    end

    def klass(class_name)
      Class.const_get("Facter::#{@os}::" + class_name.to_s)
    end

    def load_core_facts(fact_name, klass)
      loaded_fact = LoadedFact.new(fact_name, klass, :core)
      @core_facts << loaded_fact
    end

    def load_legacy_fact(fact_name, klass)
      loaded_fact = LoadedFact.new(fact_name, klass, :legacy)
      @legacy_facts << loaded_fact
    end

    def legacy_fact?(klass)
      klass.const_defined?('FACT_TYPE') && klass::FACT_TYPE.equal?(:legacy)
    end
  end
end
