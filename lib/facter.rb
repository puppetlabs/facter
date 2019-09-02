# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/utils/file_loader"

module Facter
  def self.to_hash
    Facter::Base.new.resolve_facts([])
  end

  def self.to_hocon(*args)
    fact_collection = Facter::Base.new.resolve_facts(args)
    FactFormatter.new(args, fact_collection).to_hocon
  end

  def self.value(*args)
    Facter::Base.new.resolve_facts(args)
  end

  class Base
    def resolve_facts(user_query)
      os = OsDetector.detect_family
      legacy_flag = false
      loaded_facts_hash = if user_query.any? || legacy_flag
                            Facter::FactLoader.load_with_legacy(os)
                          else
                            Facter::FactLoader.load(os)
                          end

      searched_facts = Facter::QueryParser.parse(user_query, loaded_facts_hash)
      resolve_matched_facts(searched_facts)
    end

    private

    def resolve_matched_facts(searched_facts)
      threads = start_threads(searched_facts)
      searched_facts = join_threads(threads, searched_facts)

      FactFilter.new.filter_facts!(searched_facts)

      FactCollection.new.build_fact_collection!(searched_facts)
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
        fact_class.new(searched_fact.filter_tokens).call_the_resolver(filter_criteria)
      else
        fact_class.new(searched_fact.filter_tokens).call_the_resolver
      end
    end

    def join_threads(threads, searched_facts)
      facts = []

      threads.each do |thread|
        thread.join
        facts << thread.value
      end
      facts.flatten!

      enrich_searched_fact_with_values(searched_facts, facts)
    end

    def enrich_searched_fact_with_values(searched_facts, facts)
      complete_searched_facts = []

      facts.each do |fact|
        matched_facts = searched_facts.select { |searched_fact| fact.name.match(searched_fact.name) }
        matched_fact = matched_facts.first
        searched_fact = SearchedFact.new(fact.name,
                                         matched_fact.fact_class, matched_fact.filter_tokens, matched_fact.user_query)
        searched_fact.value = fact.value
        complete_searched_facts << searched_fact
      end

      complete_searched_facts
    end
  end
end
