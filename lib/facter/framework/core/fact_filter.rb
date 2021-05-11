# frozen_string_literal: true

module Facter
  class FactFilter
    def filter_facts!(resolved_facts, user_query)
      filter_legacy_facts!(resolved_facts) if user_query.empty?
      filter_blocked_legacy_facts!(resolved_facts)
      resolved_facts
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
