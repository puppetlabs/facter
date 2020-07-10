# frozen_string_literal: true

module Facter
  class FactManager
    include Singleton

    def initialize
      @internal_fact_mgr = InternalFactManager.new
      @external_fact_mgr = ExternalFactManager.new
      @fact_loader = FactLoader.instance
      @log = Log.new(self)
    end

    def searched_facts(user_query = [])
      loaded_facts = @fact_loader.load(Options.get)
      QueryParser.parse(user_query, loaded_facts)
    end

    def resolve_facts(user_query = [])
      loaded_facts = @fact_loader.load(Options.get)
      searched_facts = QueryParser.parse(user_query, loaded_facts)

      cache_manager = Facter::CacheManager.new
      searched_facts, cached_facts = cache_manager.resolve_facts(searched_facts)
      internal_facts = @internal_fact_mgr.resolve_facts(searched_facts)
      external_facts = @external_fact_mgr.resolve_facts(searched_facts)

      resolved_facts = override_core_facts(internal_facts, external_facts)

      cache_manager.cache_facts(resolved_facts)
      resolved_facts = resolved_facts.concat(cached_facts)

      FactFilter.new.filter_facts!(resolved_facts)

      resolved_facts
    end

    def resolve_core(user_query = [])
      loaded_facts_hash = @fact_loader.internal_facts

      searched_facts = QueryParser.parse(user_query, loaded_facts_hash)
      resolved_facts = @internal_fact_mgr.resolve_facts(searched_facts)
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
  end
end
