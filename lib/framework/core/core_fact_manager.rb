# frozen_string_literal: true

module Facter
  class CoreFactManager
    def resolve_facts(searched_facts)
      threads = start_threads(searched_facts)
      resolved_facts = join_threads(threads, searched_facts)

      resolved_facts
    end

    private

    def start_threads(searched_facts)
      threads = []

      searched_facts.reject { |elem| elem.fact_class.nil? }.each do |searched_fact|
        threads << Thread.new do
          fact = Facter::FactFactory.build(searched_fact)
          fact.create
        end
      end

      threads
    end

    def join_threads(threads, searched_facts)
      resolved_facts = []

      threads.each do |thread|
        thread.join
        resolved_facts << thread.value
      end

      resolved_facts.flatten!

      FactAugmenter.augment_resolved_facts(searched_facts, resolved_facts)
    end
  end
end
