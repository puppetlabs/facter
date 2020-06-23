# frozen_string_literal: true

module Facter
  # Filter inside value of a fact.
  # e.g. os.release.major is the user query, os.release is the fact
  # and major is the filter criteria inside tha fact
  class FactFilter
    def filter_facts!(searched_facts)
      filter_legacy_facts!(searched_facts)
      searched_facts.each do |fact|
        fact.value = if fact.filter_tokens.any? && fact.value.respond_to?(:dig)
                       fact.value.dig(*fact.filter_tokens)
                     else
                       fact.value
                     end
      end
    end

    private

    def filter_legacy_facts!(resolved_facts)
      return unless !Options[:show_legacy] && Options[:user_query].empty?

      resolved_facts.reject!(&:legacy?)
    end
  end
end
