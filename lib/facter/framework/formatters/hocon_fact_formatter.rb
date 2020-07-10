# frozen_string_literal: true

module Facter
  class HoconFactFormatter
    def initialize
      @log = Log.new(self)
    end

    def format(resolved_facts)
      user_queries = resolved_facts.uniq(&:user_query).map(&:user_query)

      return if user_queries.count < 1
      return format_for_multiple_user_queries(user_queries, resolved_facts) if user_queries.count > 1

      user_query = user_queries.first
      return format_for_no_query(resolved_facts) if user_query.empty?
      return format_for_single_user_query(user_queries.first, resolved_facts) unless user_query.empty?
    end

    private

    def format_for_no_query(resolved_facts)
      @log.debug('Formatting for no user query')
      fact_collection = FormatterHelper.retrieve_fact_collection(resolved_facts)
      hash_to_hocon(fact_collection)
    end

    def format_for_multiple_user_queries(user_queries, resolved_facts)
      @log.debug('Formatting for multiple user queries')

      facts_to_display = FormatterHelper.retrieve_facts_to_display_for_user_query(user_queries, resolved_facts)
      hash_to_hocon(facts_to_display)
    end

    def format_for_single_user_query(user_query, resolved_facts)
      @log.debug('Formatting for single user query')

      fact_value = FormatterHelper.retrieve_fact_value_for_single_query(user_query, resolved_facts)

      return '' unless fact_value

      fact_value.class == Hash ? hash_to_hocon(fact_value) : fact_value
    end

    def hash_to_hocon(fact_collection)
      render_opts = Hocon::ConfigRenderOptions.new(false, false, true, false)
      Hocon::ConfigFactory.parse_string(fact_collection.to_json).root.render(render_opts)
    end
  end
end
