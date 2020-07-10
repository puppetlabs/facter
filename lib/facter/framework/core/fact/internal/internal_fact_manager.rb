# frozen_string_literal: true

module Facter
  class InternalFactManager
    @@log = Facter::Log.new(self)

    def resolve_facts(searched_facts)
      internal_searched_facts = filter_internal_facts(searched_facts)
      threads = start_threads(internal_searched_facts)
      resolved_facts = join_threads(threads, internal_searched_facts)

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

    def start_threads(searched_facts)
      threads = []
      # only resolve a fact once, even if multiple search facts depend on that fact
      searched_facts
        .uniq { |searched_fact| searched_fact.fact_class.name }
        .each do |searched_fact|
        threads << Thread.new do
          begin
            fact = CoreFact.new(searched_fact)
            fact.create
          rescue StandardError => e
            @@log.error(e.message + ' ' + e.backtrace.join("\n"))
            nil
          end
        end
      end

      threads
    end

    def join_threads(threads, searched_facts)
      resolved_facts = []

      threads.each do |thread|
        thread.join
        resolved_facts << thread.value unless thread.value.nil?
      end

      resolved_facts.flatten!

      FactAugmenter.augment_resolved_facts(searched_facts, resolved_facts)
    end
  end
end
