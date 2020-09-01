# frozen_string_literal: true

module Facter
  class FactLoader
    include Singleton

    attr_reader :internal_facts, :external_facts, :facts

    def initialize
      @log = Log.new(self)

      @internal_facts = []
      @external_facts = []
      @facts = []
    end

    def load(options)
      @internal_loader ||= InternalFactLoader.new
      @external_fact_loader ||= ExternalFactLoader.new

      @facts = []
      @external_facts = []
      load_internal_facts(options)
      load_external_facts(options)

      @facts
    end

    private

    def load_internal_facts(options)
      @log.debug('Loading internal facts')

      if options[:user_query] || options[:show_legacy]
        # if we have a user query, then we must search in core facts and legacy facts
        @log.debug('Loading all internal facts')
        @internal_facts = @internal_loader.facts
      else
        @log.debug('Load only core facts')
        @internal_facts = @internal_loader.core_facts
      end

      @internal_facts = block_facts(@internal_facts, options)
      @facts.concat(@internal_facts)
    end

    def load_external_facts(options)
      @log.debug('Loading external facts')
      if options[:custom_facts]
        @log.debug('Loading custom facts')
        @external_facts.concat(@external_fact_loader.custom_facts)
      end

      @external_facts = block_facts(@external_facts, options)

      if options[:external_facts]
        @log.debug('Loading external facts')
        @external_facts.concat(@external_fact_loader.external_facts)
      end

      @facts.concat(@external_facts)
    end

    def block_facts(facts, options)
      blocked_facts = options[:blocked_facts] || []

      reject_list_core, reject_list_legacy = construct_reject_lists(blocked_facts, facts)

      facts = facts.reject do |fact|
        reject_list_core.include?(fact) || reject_list_core.find do |fact_to_block|
          fact_to_block.klass == fact.klass
        end || reject_list_legacy.include?(fact)
      end

      facts
    end

    def construct_reject_lists(blocked_facts, facts)
      reject_list_core = []
      reject_list_legacy = []

      blocked_facts.each do |blocked|
        facts.each do |fact|
          next unless fact.name =~ /^#{blocked}/

          if fact.type == :core
            reject_list_core << fact
          else
            reject_list_legacy << fact
          end
        end
      end

      [reject_list_core, reject_list_legacy]
    end
  end
end
