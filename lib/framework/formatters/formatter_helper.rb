# frozen_string_literal: true

module Facter
  class FormatterHelper
    class << self
      def retrieve_facts_to_display_for_user_query(user_queries, resolved_facts)
        facts_to_display = {}
        user_queries.each do |user_query|
          fact_collection = build_fact_collection_for_user_query(user_query, resolved_facts)

          printable_value = fact_collection.dig(*user_query.split('.').map(&:to_sym))
          facts_to_display.merge!(user_query => printable_value)
        end

        Facter::Utils.sort_hash_by_key(facts_to_display)
      end

      def retrieve_fact_collection(resolved_facts)
        fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
        Facter::Utils.sort_hash_by_key(fact_collection)
      end

      def retrieve_fact_value_for_single_query(user_query, resolved_facts)
        fact_collection = build_fact_collection_for_user_query(user_query, resolved_facts)
        fact_collection = Facter::Utils.sort_hash_by_key(fact_collection)
        fact_collection.dig(*user_query.split('.').map(&:to_sym))
      end

      private

      def build_fact_collection_for_user_query(user_query, resolved_facts)
        facts_for_query = resolved_facts.select { |resolved_fact| resolved_fact.user_query == user_query }
        FactCollection.new.build_fact_collection!(facts_for_query)
      end
    end
  end
end
