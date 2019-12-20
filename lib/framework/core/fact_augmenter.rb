# frozen_string_literal: true

module Facter
  module FactAugmenter
    def self.augment_resolved_facts(searched_facts, resolved_facts)
      augumented_resolved_facts = []
      searched_facts.each do |searched_fact|
        matched_facts = get_resolved_facts_for_searched_fact(searched_fact, resolved_facts)
        augment_resolved_fact_for_user_query!(searched_fact, matched_facts)
        augumented_resolved_facts.concat(matched_facts)
      end

      augumented_resolved_facts
    end

    private_class_method def self.get_resolved_facts_for_searched_fact(searched_fact, resolved_facts)
      if searched_fact.name.include?('.*')
        resolved_facts
          .select { |resolved_fact| resolved_fact.name.match(searched_fact.user_query) }
          .reject(&:user_query)
          .uniq(&:name)
      else
        resolved_facts
          .select { |resolved_fact| searched_fact.name.match(resolved_fact.name) }
          .reject(&:user_query)
          .uniq(&:name)
      end
    end

    private_class_method def self.augment_resolved_fact_for_user_query!(searched_fact, matched_facts)
      matched_facts.each do |matched_fact|
        matched_fact.user_query = searched_fact.user_query
        matched_fact.filter_tokens = searched_fact.filter_tokens
      end
    end
  end
end
