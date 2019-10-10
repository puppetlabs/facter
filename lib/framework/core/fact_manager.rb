# frozen_string_literal: true

require 'singleton'

module Facter
  class FactManager
    include Singleton

    def initialize
      @core_fact_mgr = CoreFactManager.new
      @custom_fact_mgr = CustomFactManager.new
      @fact_loader = InternalFactLoader.new
      @custom_fact_loader = ExternalFactLoader.new
    end

    def resolve_facts(options = {}, user_query = [])
      loaded_facts_hash = user_query.any? || options[:show_legacy] ? load_all_facts : load_core_with_custom
      searched_facts = QueryParser.parse(user_query, loaded_facts_hash)

      core_facts = resolve_core_facts(searched_facts)
      custom_facts = resolve_custom_facts(searched_facts)

      resolved_facts = override_core_facts(core_facts, custom_facts)
      FactFilter.new.filter_facts!(resolved_facts)

      resolved_facts
    end

    def resolve_core(_options = {}, user_query = [])
      loaded_facts_hash = @fact_loader.core_facts

      searched_facts = QueryParser.parse(user_query, loaded_facts_hash)
      resolved_facts = resolve_core_facts(searched_facts)
      FactFilter.new.filter_facts!(resolved_facts)

      resolved_facts
    end

    private

    def override_core_facts(core_facts, custom_facts)
      return core_facts unless custom_facts

      custom_facts.each do |custom_fact|
        core_facts.delete_if { |core_fact| root_fact_name(core_fact) == custom_fact.name }
      end

      core_facts + custom_facts
    end

    def root_fact_name(fact)
      fact.name.split('.').first
    end

    def load_all_facts
      loaded_facts_hash = {}
      loaded_facts_hash.merge!(@fact_loader.facts)
      loaded_facts_hash.merge!(@custom_fact_loader.facts)
    end

    def load_core_with_custom
      loaded_facts_hash = {}
      loaded_facts_hash.merge!(@fact_loader.core_facts)
      loaded_facts_hash.merge!(@custom_fact_loader.facts)
    end

    def resolve_core_facts(searched_facts)
      @core_fact_mgr.resolve_facts(searched_facts.reject { |searched_fact| searched_fact.fact_class.nil? })
    end

    def resolve_custom_facts(searched_facts)
      custom_facts = @custom_fact_loader.facts
      searched_custom_facts =
        searched_facts.select { |searched_fact| custom_facts.fetch(searched_fact.name, 'no_value').nil? }

      @custom_fact_mgr.resolve_facts(searched_custom_facts)
    end
  end
end
