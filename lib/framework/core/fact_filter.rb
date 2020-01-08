# frozen_string_literal: true

module Facter
  # Filter inside value of a fact.
  # e.g. os.release.major is the user query, os.release is the fact
  # and major is the filter criteria inside tha fact
  class FactFilter
    def filter_facts!(searched_facts)
      filter_legacy_facts!(searched_facts)
      searched_facts.each do |fact|
        fact.value = symbolize_all_keys(fact.value) if fact.value.is_a?(Hash)
        fact.value = fact.filter_tokens.any? ? fact.value.dig(*fact.filter_tokens) : fact.value
      end
    end

    private

    def symbolize_all_keys(hash)
      symbolized_hash = {}
      hash.each do |k, v|
        symbolized_hash[k.to_sym] = v.is_a?(Hash) ? symbolize_all_keys(v) : v
      end
      symbolized_hash
    end

    def filter_legacy_facts!(resolved_facts)
      return if Options.get[:show_legacy]

      resolved_facts.reject!(&:legacy?) unless Options.get[:user_query]
    end
  end
end
