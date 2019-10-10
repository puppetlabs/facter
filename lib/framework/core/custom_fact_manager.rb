# frozen_string_literal: true

module Facter
  class CustomFactManager
    def resolve_facts(searched_facts)
      custom_facts(searched_facts)
    end

    private

    def custom_facts(custom_facts)
      LegacyFacter.search("#{ROOT_DIR}/custom_facts")
      LegacyFacter.search_external(["#{ROOT_DIR}/external_facts"])

      resolved_custom_facts = []

      custom_facts.each do |custom_fact|
        fact_value = LegacyFacter.value(custom_fact.name)
        resolved_fact = ResolvedFact.new(custom_fact.name, fact_value)
        resolved_fact.filter_tokens = []
        resolved_fact.user_query = custom_fact.user_query

        resolved_custom_facts << resolved_fact
      end

      resolved_custom_facts
    end
  end
end
