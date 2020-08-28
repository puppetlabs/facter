# frozen_string_literal: true

module Facter
  class InternalFactManager
    @@log = Facter::Log.new(self)

    def resolve_facts(searched_facts)
      internal_searched_facts = filter_internal_facts(searched_facts)

      resolved_facts = resolve(internal_searched_facts)
      nil_resolved_facts = resolve_nil_facts(searched_facts)

      resolved_facts.concat(nil_resolved_facts)
    end

    private

    def filter_internal_facts(searched_facts)
      searched_facts.select { |searched_fact| %i[core legacy].include? searched_fact.type }
    end

    def resolve_nil_facts(searched_facts)
      resolved_facts = []
      searched_facts.select { |fact| fact.type == :nil }.each do |fact|
        resolved_facts << ResolvedFact.new(fact.name, nil, :nil, fact.name)
      end

      resolved_facts
    end

    def resolve(searched_facts)
      resolved_facts = []

      searched_facts
        .uniq { |searched_fact| searched_fact.fact_class.name }
        .each do |searched_fact|
        begin
          fact = CoreFact.new(searched_fact)
          fact_value = fact.create
          resolved_facts << fact_value unless fact_value.nil?
        rescue StandardError => e
          @@log.log_exception(e)
        end
      end

      resolved_facts.flatten!
      FactAugmenter.augment_resolved_facts(searched_facts, resolved_facts)
    end
  end
end
