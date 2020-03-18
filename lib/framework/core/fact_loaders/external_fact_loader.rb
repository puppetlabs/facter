# frozen_string_literal: true

module Facter
  class ExternalFactLoader
    def custom_facts
      @custom_facts ||= load_custom_facts
    end

    def external_facts
      @external_facts ||= load_external_facts
    end

    def all_facts
      @all_facts ||= Utils.deep_copy(custom_facts + external_facts)
    end

    private

    # The search paths must be set before creating the fact collection.
    # If we set them after, they will not be visible.
    def load_search_paths
      LegacyFacter.search(*Options.custom_dir) if Options.custom_dir?
      LegacyFacter.search_external(Options.external_dir) if Options.external_dir?
    end

    def load_custom_facts
      custom_facts = []

      load_search_paths
      custom_facts_to_load = LegacyFacter.collection.custom_facts

      custom_facts_to_load&.each do |custom_fact_name|
        loaded_fact = LoadedFact.new(custom_fact_name.to_s, nil, :custom)
        custom_facts << loaded_fact
      end

      custom_facts
    end

    def load_external_facts
      external_facts = []

      load_search_paths
      external_facts_to_load = LegacyFacter.collection.external_facts

      external_facts_to_load&.each do |external_fact_name|
        loaded_fact = LoadedFact.new(external_fact_name.to_s, nil, :external)
        external_facts << loaded_fact
      end

      external_facts
    end
  end
end
