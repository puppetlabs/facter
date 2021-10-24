# frozen_string_literal: true

module Facter
  class ExternalFactLoader
    def custom_facts
      @custom_facts = load_custom_facts
    end

    def external_facts
      @external_facts = load_external_facts
    end

    def load_fact(fact_name)
      build_custom_facts(LegacyFacter.collection.custom_fact(fact_name)) || []
    end

    private

    def load_custom_facts
      custom_facts_to_load = LegacyFacter.collection.custom_facts
      build_custom_facts(custom_facts_to_load) || []
    end

    def build_custom_facts(custom_facts_to_load)
      custom_facts_to_load&.map do |k, v|
        loaded_fact = LoadedFact.new(k.to_s, nil, :custom)
        loaded_fact.is_env = v.options[:is_env] if v.options[:is_env]
        loaded_fact
      end
    end

    def load_external_facts
      external_facts = []

      external_facts_to_load = LegacyFacter.collection.external_facts

      external_facts_to_load&.each do |k, v|
        loaded_fact = LoadedFact.new(k.to_s, nil, :external)
        loaded_fact.file = v.options[:file]
        loaded_fact.is_env = v.options[:is_env]
        external_facts << loaded_fact
      end

      external_facts
    end
  end
end
