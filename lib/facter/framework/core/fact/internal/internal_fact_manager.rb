# frozen_string_literal: true

module Facter
  class InternalFactManager
    @@log = Facter::Log.new(self)

    def resolve_facts(searched_facts)
      internal_searched_facts = filter_internal_facts(searched_facts)

      resolved_facts = if Options[:parallel]
                         @@log.debug('Resolving fact in parallel')
                         threads = start_threads(internal_searched_facts)
                         join_threads(threads, internal_searched_facts)
                         # thread_pool(internal_searched_facts)
                       else
                         @@log.debug('Resolving facts sequentially')
                         resolve_sequentially(internal_searched_facts)
                       end

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

    def resolve_sequentially(searched_facts)
      resolved_facts = []

      searched_facts
        .uniq { |searched_fact| searched_fact.fact_class.name }
        .each do |searched_fact|
        begin
          fact = CoreFact.new(searched_fact)
          fact_value = nil
          Facter::Framework::Benchmarking::Timer.measure(searched_fact.name) { fact_value = fact.create }
          resolved_facts << fact_value unless fact_value.nil?
        rescue StandardError => e
          @@log.log_exception(e)
        end
      end

      resolved_facts.flatten!
      FactAugmenter.augment_resolved_facts(searched_facts, resolved_facts)
    end

    def start_threads(searched_facts)
      threads = []
      # only resolve a fact once, even if multiple search facts depend on that fact
      searched_facts
        .uniq { |searched_fact| searched_fact.fact_class.name }
        .each do |searched_fact|
        threads << Thread.new do
          resolve_fact(searched_fact)
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

    def thread_pool(searched_facts)
      require 'concurrent'

      pool = Concurrent::FixedThreadPool.new(12)
      pr_futures = []

      searched_facts
        .uniq { |searched_fact| searched_fact.fact_class.name }
        .each do |searched_fact|
          pr_futures << Concurrent::Promises.future_on(pool) do
            resolve_fact(searched_fact)
          end
        end

      resolved_facts = Concurrent::Promises.zip(*pr_futures).value!.flatten.compact

      FactAugmenter.augment_resolved_facts(searched_facts, resolved_facts)
    end

    def resolve_fact(searched_fact)
      fact = CoreFact.new(searched_fact)
      fact.create
    rescue StandardError => e
      @@log.log_exception(e)
      nil
    end
  end
end
