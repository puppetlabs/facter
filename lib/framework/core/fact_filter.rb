# frozen_string_literal: true

module Facter
  # Filter inside value of a fact.
  # e.g. os.release.major is the user query, os.release is the fact
  # and major is the filter criteria inside tha fact
  class FactFilter
    def filter_facts!(searched_facts)
      searched_facts.each do |fact|
        fact.value = symbolize_all_keys(fact.value)
        fact.value = fact.filter_tokens.any? ? fact.value.dig(*fact.filter_tokens.map(&:to_sym)) : fact.value
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
  end
end
