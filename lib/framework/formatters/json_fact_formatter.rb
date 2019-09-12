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

      fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
      fact_collection = Facter::Utils.sort_hash_by_key(fact_collection)
      JSON.pretty_generate(fact_collection)
    end

    def format_for_user_queries(user_queries, resolved_facts)
      @log.debug('User provided a query')

      facts_to_display = {}
      user_queries.each do |user_query|
        fact_collection = build_fact_collection_for_user_query(user_query, resolved_facts)

        printable_value = fact_collection.dig(*user_query.split('.'))
        facts_to_display.merge!(user_query => printable_value)
      end

      facts_to_display = Facter::Utils.sort_hash_by_key(facts_to_display)
      JSON.pretty_generate(facts_to_display)
    end

    def build_fact_collection_for_user_query(user_query, resolved_facts)
      facts_for_query = resolved_facts.select { |resolved_fact| resolved_fact.user_query == user_query }
      FactCollection.new.build_fact_collection!(facts_for_query)
    end
  end
end
