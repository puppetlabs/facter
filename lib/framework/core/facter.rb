# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('../../..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/framework/core/file_loader"

module Facter
  def self.to_hash
    resolved_facts = Facter::Base.new.resolve_facts
    ResolverManager.invalidate_all_caches
    FactCollection.new.build_fact_collection!(resolved_facts)
  end

  def self.to_user_output(options, *args)
    resolved_facts = Facter::Base.new.resolve_facts(options, args)
    ResolverManager.invalidate_all_caches
    fact_formatter = Facter::FormatterFactory.build(options)
    fact_formatter.format(resolved_facts)
  end

  def self.value(user_query)
    resolved_facts = Facter::Base.new.resolve_facts({}, [user_query])
    ResolverManager.invalidate_all_caches
    fact_collection = FactCollection.new.build_fact_collection!(resolved_facts)
    fact_collection.dig(*user_query.split('.'))
  end

  class Base
    def resolve_facts(options = {}, user_query = [])
      os = CurrentOs.instance.identifier
      loaded_facts_hash = if user_query.any? || options[:show_legacy]
                            Facter::FactLoader.load_with_legacy(os)
                          else
                            Facter::FactLoader.load(os)
                          end

      searched_facts = Facter::QueryParser.parse(user_query, loaded_facts_hash)
      resolve_matched_facts(searched_facts)
    end

    private

    def resolve_matched_facts(resolved_facts)
      threads = start_threads(resolved_facts)
      resolved_facts = join_threads(threads, resolved_facts)
      FactFilter.new.filter_facts!(resolved_facts)

      resolved_facts
    end

    def start_threads(searched_facts)
      threads = []

      searched_facts.each do |searched_fact|
        threads << Thread.new do
          create_fact(searched_fact)
        end
      end

      threads
    end

    def create_fact(searched_fact)
      fact_class = searched_fact.fact_class
      if searched_fact.name.end_with?('.*')
        fact_without_wildcard = searched_fact.name[0..-3]
        filter_criteria = searched_fact.user_query.split(fact_without_wildcard).last
        fact_class.new.call_the_resolver(filter_criteria)
      else
        fact_class.new.call_the_resolver
      end
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
