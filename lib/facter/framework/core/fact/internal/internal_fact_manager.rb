# frozen_string_literal: true

module Facter
  class InternalFactManager
    # resolves each SearchFact and filter out facts that do not match the given user query
    # @param searched_facts [Array<Facter::SearchedFact>] array of searched facts
    #
    # @return [Array<Facter::ResolvedFact>]
    #
    # @api private
    def resolve_facts(searched_facts)
      internal_searched_facts = filter_internal_facts(searched_facts)
      resolved_facts = if Options[:sequential]
                         resolve_sequentially(internal_searched_facts)
                       else
                         resolve_in_parallel(internal_searched_facts)
                       end

      resolved_facts.flatten!
      resolved_facts.compact!

      nil_resolved_facts = resolve_nil_facts(searched_facts)

      resolved_facts.concat(nil_resolved_facts)
    end

    private

    def filter_internal_facts(searched_facts)
      searched_facts.select { |searched_fact| %i[core legacy].include? searched_fact.type }
    end

    def valid_fact?(searched_fact, resolved_fact)
      return if resolved_fact.value.nil?

      searched_fact_name = searched_fact.name
      if searched_fact_name.include?('.*')
        resolved_fact.name.match(searched_fact_name)
      else
        resolved_fact.name == searched_fact_name
      end
    end

    def resolve_nil_facts(searched_facts)
      resolved_facts = []
      searched_facts.select { |fact| fact.type == :nil }.each do |fact|
        resolved_facts << ResolvedFact.new(fact.name, nil, :nil, fact.name)
      end

      resolved_facts
    end

    def resolve_sequentially(searched_facts)
      searched_facts.map! { |searched_fact| resolve_fact(searched_fact) }
    end

    def resolve_in_parallel(searched_facts)
      searched_facts.map! do |searched_fact|
        Thread.new { resolve_fact(searched_fact) }
      end.map!(&:value)
    end

    def resolve_fact(searched_fact)
      fact_value = core_fact(searched_fact)
      Array(fact_value).map! do |resolved_fact|
        if valid_fact?(searched_fact, resolved_fact)
          resolved_fact.user_query = searched_fact.user_query
          resolved_fact
        end
      end
    end

    def core_fact(searched_fact)
      fact = CoreFact.new(searched_fact)
      fact.create
    rescue StandardError => e
      log.log_exception(e)
      nil
    end

    def log
      @log ||= Facter::Log.new(self)
    end
  end
end
