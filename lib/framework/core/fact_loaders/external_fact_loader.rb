# frozen_string_literal: true

module Facter
  class ExternalFactLoader
    attr_reader :custom_facts, :external_facts, :facts

    def initialize
      @custom_facts = []
      @external_facts = []
      @facts = []

      directories_to_search
      load_custom_facts
      load_external_facts

      all_facts
    end

    private

    def all_facts
      @facts = @custom_facts.concat(@external_facts)
    end

    def directories_to_search
      LegacyFacter.search("#{ROOT_DIR}/custom_facts")
      LegacyFacter.search_external(["#{ROOT_DIR}/external_facts"])
    end

    def load_custom_facts
      custom_facts_to_load = LegacyFacter.collection.custom_facts

      custom_facts_to_load&.each do |k, _v|
        loaded_fact = LoadedFact.new(k.to_s, nil, :custom)
        @custom_facts << loaded_fact
      end
    end

    def load_external_facts
      external_facts_to_load = LegacyFacter.collection.external_facts

      external_facts_to_load&.each do |k, _v|
        loaded_fact = LoadedFact.new(k.to_s, nil, :external)
        @external_facts << loaded_fact
      end
    end
  end
end
