# frozen_string_literal: true

module Facter
  class ExternalFactManager
    def resolve_facts(searched_facts)
      searched_facts = filter_external_facts(searched_facts)
      external_facts(searched_facts)
    end

    private

    def filter_external_facts(searched_facts)
      searched_facts.select { |searched_fact| %i[custom external].include?(searched_fact.type) }
    end

    def external_facts(custom_facts)
      custom_facts.map do |custom_fact|
        fact = LegacyFacter[custom_fact.name]
        type = fact.options[:fact_type] || :custom
        fact_attributes = Facter::FactAttributes.new(
          user_query: custom_fact.user_query,
          filter_tokens: [],
          structured: custom_fact.structured,
          file: fact.options[:file]
        )

        fact_value = if type == :external && custom_fact.structured
                       fact.options[:value]
                     else
                       fact.value
                     end

        ResolvedFact.new(custom_fact.name, fact_value, type, fact_attributes)
      end
    end
  end
end
