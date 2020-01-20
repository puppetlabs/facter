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

    def resolve_facts(options = {}, user_query = [])
      options = enhance_options(options, user_query)
      Log.level = options.get[:log_level]

      loaded_facts = @fact_loader.load(Options.get)
      searched_facts = QueryParser.parse(user_query, loaded_facts)

      internal_facts = @internal_fact_mgr.resolve_facts(searched_facts)
      external_facts = @external_fact_mgr.resolve_facts(searched_facts)

      resolved_facts = override_core_facts(internal_facts, external_facts)
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

    def enhance_options(cli_options, user_query)
      options = Options.instance
      options.augment_with_defaults!
      options.augment_with_to_hash_defaults! if cli_options[:to_hash]
      options.augment_with_config_file_options!(cli_options[:config])
      options.augment_with_cli_options!(cli_options)
      options.augment_with_helper_options!(user_query)

      options
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
  end
end
