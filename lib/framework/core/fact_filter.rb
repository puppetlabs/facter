# frozen_string_literal: true

module Facter
  # Filter inside value of a fact.
  # e.g. os.release.major is the user query, os.release is the fact
  # and major is the filter criteria inside tha fact
  class FactFilter
    def filter_facts!(searched_facts)
      searched_facts.each do |fact|
        value = fact.filter_tokens.any? ? fact.value.dig(*fact.filter_tokens.map(&:to_sym)) : fact.value
        fact.value = value
      end
    end
  end
end
