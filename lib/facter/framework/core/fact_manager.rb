# frozen_string_literal: true

module Facter
  class FactManager
    include Singleton

    def initialize
      @internal_fact_mgr = InternalFactManager.new
      @external_fact_mgr = ExternalFactManager.new
      @fact_loader = FactLoader.instance
      @options = Options.get
      @log = Log.new(self)
    end

    def resolve_facts(user_query = [])
      log_resolving_method
      @options[:user_query] = user_query
      cache_manager = Facter::CacheManager.new

      searched_facts = QueryParser.parse(user_query, @fact_loader.load(user_query, @options))

      searched_facts, cached_facts = cache_manager.resolve_facts(searched_facts)
      internal_facts = @internal_fact_mgr.resolve_facts(searched_facts)
      external_facts = @external_fact_mgr.resolve_facts(searched_facts)

      resolved_facts = override_core_facts(internal_facts, external_facts)

      resolved_facts = resolved_facts.concat(cached_facts)
      cache_manager.cache_facts(resolved_facts)

      FactFilter.new.filter_facts!(resolved_facts, user_query)

      log_resolved_facts(resolved_facts)
      resolved_facts
    end

    # resolve a fact by name, in a similar way that facter 3 does.
    # search is done in multiple steps, and the next step is executed
    # only if the previous one was not able to resolve the fact
    # - load the `fact_name.rb` from the configured custom directories
    # - load all the core facts, external facts and env facts
    # - load all custom facts
    def resolve_fact(user_query)
      log_resolving_method
      @options[:user_query] = user_query
      @log.debug("resolving fact with user_query: #{user_query}")

      @cache_manager = Facter::CacheManager.new

      custom_facts = custom_fact_by_filename(user_query) || []
      core_and_external_facts = core_or_external_fact(user_query) || []
      resolved_facts = core_and_external_facts + custom_facts

      if resolved_facts.empty? || resolved_facts.none? { |rf| rf.resolves?(user_query) }
        resolved_facts.concat(all_custom_facts(user_query))
      end

      @cache_manager.cache_facts(resolved_facts)

      log_resolved_facts(resolved_facts)
      resolved_facts
    end

    def resolve_core(user_query = [], options = {})
      log_resolving_method
      @cache_manager = CacheManager.new
      core_fact(user_query, options)
    end

    private

    def log_resolving_method
      if Options[:sequential]
        @log.debugonce('Resolving facts sequentially')
      else
        @log.debugonce('Resolving fact in parallel')
      end
    end

    def core_fact(user_query, options)
      loaded_facts_hash = @fact_loader.load_internal_facts(user_query, options)

      searched_facts = QueryParser.parse(user_query, loaded_facts_hash)
      searched_facts, cached_facts = @cache_manager.resolve_facts(searched_facts)

      resolved_facts = @internal_fact_mgr.resolve_facts(searched_facts)
      resolved_facts = resolved_facts.concat(cached_facts)

      FactFilter.new.filter_facts!(resolved_facts, user_query)

      resolved_facts
    end

    def custom_fact_by_filename(user_query)
      @log.debug("Searching fact: #{user_query} in file: #{user_query}.rb")

      custom_fact = @fact_loader.load_custom_fact(@options, user_query)
      return unless custom_fact.any?

      searched_facts = parse_user_query(custom_fact, user_query)
      searched_facts, cached_facts = @cache_manager.resolve_facts(searched_facts)

      resolved_facts = @external_fact_mgr.resolve_facts(searched_facts)
      resolved_facts = resolved_facts.concat(cached_facts)
      resolved_facts if resolved_facts.any?
    end

    def core_or_external_fact(user_query)
      @log.debug("Searching fact: #{user_query} in core facts and external facts")

      core_facts = core_fact([user_query], @options)
      external_facts = @fact_loader.load_external_facts(@options)
      searched_facts = parse_user_query(external_facts, user_query)
      searched_facts, cached_facts = @cache_manager.resolve_facts(searched_facts)

      resolved_facts = @external_fact_mgr.resolve_facts(searched_facts)
      resolved_facts = override_core_facts(core_facts, resolved_facts)
      resolved_facts = resolved_facts.concat(cached_facts)

      resolved_facts unless resolved_facts.map(&:value).compact.empty?
    end

    def all_custom_facts(user_query)
      @log.debug("Searching fact: #{user_query} in all custom facts")

      custom_facts = @fact_loader.load_custom_facts(@options)
      searched_facts = parse_user_query(custom_facts, user_query)
      searched_facts, cached_facts = @cache_manager.resolve_facts(searched_facts)

      resolved_facts = @external_fact_mgr.resolve_facts(searched_facts)
      resolved_facts.concat(cached_facts)
    end

    def parse_user_query(loaded_facts, user_query)
      user_query = Array(user_query)
      QueryParser.parse(user_query, loaded_facts)
    end

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

    def log_resolved_facts(resolved_facts)
      resolved_facts.each do |fact|
        @log.debug("fact \"#{fact.name}\" has resolved to: #{fact.value}") unless fact.value.nil?
      end
    end
  end
end
