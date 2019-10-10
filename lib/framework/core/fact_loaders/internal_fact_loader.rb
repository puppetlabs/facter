# frozen_string_literal: true

module Facter
  class InternalFactLoader
    attr_reader :core_facts, :legacy_facts, :facts

    def initialize
      @core_facts = {}
      @legacy_facts = {}
      @facts = {}

      load
    end

    private

    def load
      os = CurrentOs.instance.identifier.capitalize

      # select only classes
      classes = ClassDiscoverer.instance.discover_classes(os)

      classes.each do |class_name|
        klass = Class.const_get("Facter::#{os}::" + class_name.to_s)
        fact_name = klass::FACT_NAME

        if legacy_fact?(klass)
          @legacy_facts.merge!(fact_name => klass)
        else
          @core_facts.merge!(fact_name => klass)
        end
      end

      @facts = @legacy_facts.merge(@core_facts)

      @facts
    end

    def legacy_fact?(klass)
      klass.const_defined?('FACT_TYPE') && klass::FACT_TYPE.equal?(:legacy)
    end
  end
end
