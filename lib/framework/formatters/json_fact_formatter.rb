# frozen_string_literal: true

module Facter
  class JsonFactFormatter
    def initialize
      @log = Facter::Log.new
    end

    def format(resolved_facts)
      user_queries = resolved_facts.uniq(&:user_query).map(&:user_query)

      if user_queries.count == 1 && user_queries.first.empty?
        format_for_no_query(resolved_facts)
      else
        format_for_user_queries(user_queries, resolved_facts)
      end
    end

    private

    def format_for_no_query(resolved_facts)
      @log.debug('No user query provided')

      fact_collection = FormatterHelper.retrieve_fact_collection(resolved_facts)
      JSON.pretty_generate(fact_collection)
    end

    def format_for_user_queries(user_queries, resolved_facts)
      @log.debug('User provided a query')

      facts_to_display = FormatterHelper.retrieve_facts_to_display_for_user_query(user_queries, resolved_facts)
      JSON.pretty_generate(facts_to_display)
    end
  end
end
