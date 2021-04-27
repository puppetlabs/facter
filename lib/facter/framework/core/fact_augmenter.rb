# frozen_string_literal: true

module Facter
  module FactAugmenter
    class << self
      def augment_resolved_facts(searched_facts, resolved_facts)
        augumented_resolved_facts = []
        searched_facts.each do |searched_fact|
          matched_facts = get_resolved_facts_for_searched_fact(searched_fact, resolved_facts)
          augment_resolved_fact_for_user_query!(searched_fact, matched_facts)
          augumented_resolved_facts.concat(matched_facts)
        end

        augumented_resolved_facts
      end

      private

      def get_resolved_facts_for_searched_fact(searched_fact, resolved_facts)
        criteria = if searched_fact.name.include?('.*')
                     ->(resolved_fact) { resolved_fact.name.match(searched_fact.name) }
                   else
                     ->(resolved_fact) { valid_fact?(searched_fact, resolved_fact) }
                   end

        resolved_facts.select(&criteria).reject(&:user_query).uniq(&:name)
      end

      def augment_resolved_fact_for_user_query!(searched_fact, matched_facts)
        matched_facts.each do |matched_fact|
          matched_fact.user_query = searched_fact.user_query
        end
      end

      def valid_fact?(searched_fact, resolved_fact)
        return false unless searched_fact.name == resolved_fact.name
        return true unless searched_fact.filter_tokens.any?

        fact_value = resolved_fact.value
        return false unless fact_value.respond_to?(:dig)

        begin
          return true if fact_value.dig(*searched_fact.filter_tokens)
        rescue StandardError
          false
        end
      end
    end
  end
end
