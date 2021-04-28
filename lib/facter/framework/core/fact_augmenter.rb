# frozen_string_literal: true

module Facter
  module FactAugmenter
    class << self
      def augment_resolved_facts(searched_facts, resolved_facts)
        searched_facts.reduce([]) do |result, searched_fact|
          matched_facts = get_resolved_facts_for_searched_fact(searched_fact, resolved_facts)
          augment_resolved_fact_for_user_query!(searched_fact, matched_facts)
          result + matched_facts
        end
      end

      private

      def get_resolved_facts_for_searched_fact(searched_fact, resolved_facts)
        criteria = ->(resolved_fact) { valid_fact?(searched_fact, resolved_fact) }
        resolved_facts.select(&criteria).reject(&:user_query).uniq(&:name)
      end

      def augment_resolved_fact_for_user_query!(searched_fact, matched_facts)
        matched_facts.each { |mf| mf.user_query = searched_fact.user_query }
      end

      def valid_fact?(searched_fact, resolved_fact)
        searched_fact_name = searched_fact.name
        if searched_fact_name.include?('.*')
          resolved_fact.name.match(searched_fact_name)
        else
          resolved_fact.name == searched_fact_name
        end
      end
    end
  end
end
