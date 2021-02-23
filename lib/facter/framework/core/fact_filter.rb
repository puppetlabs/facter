# frozen_string_literal: true

module Facter
  # Filter inside value of a fact.
  # e.g. os.release.major is the user query, os.release is the fact
  # and major is the filter criteria inside tha fact
  class FactFilter
    def filter_facts!(searched_facts, user_query)
      filter_legacy_facts!(searched_facts) if user_query.empty?
      filter_blocked_legacy_facts!(searched_facts)

      searched_facts.each do |fact|
        fact.value = if fact.filter_tokens.any? && fact.value.respond_to?(:dig)
                       fact.value.dig(*fact.filter_tokens)
                     else
                       fact.value
                     end
      end
    end

    private

    # This will filter out the legacy facts that should be blocked. Because some legacy facts are just aliases
    # to the core ones, even if they are blocked, facter will resolved them but they won't be displayed.

    def filter_blocked_legacy_facts!(facts)
      blocked_facts = Options[:blocked_facts] || []

      facts.reject! do |fact|
        blocked_facts.select { |blocked_fact| fact.name.match(/^#{blocked_fact}/) && fact.type == :legacy }.any?
      end
    end

    def filter_legacy_facts!(resolved_facts)
      return if Options[:show_legacy]

      resolved_facts.reject!(&:legacy?)
    end
  end
end
