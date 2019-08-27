# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/utils/file_loader"

module Facter
  def self.to_hash
    Facter::Base.new([])
  end

  def self.value(*args)
    Facter::Base.new(args)
  end

  class Base
    def initialize(user_query)
      os = OsDetector.detect_family
      loaded_facts_hash = Facter::FactLoader.load(os)
      searched_facts = Facter::QueryParser.parse(user_query, loaded_facts_hash)
      resolve_matched_facts(user_query, searched_facts)
    end

    private

    def resolve_matched_facts(user_query, searched_facts)
      threads = start_threads(searched_facts)
      join_threads!(threads, searched_facts)

      FactFilter.new.filter_facts!(searched_facts)
      fact_collection = FactCollection.new.build_fact_collection!(searched_facts)

      fact_formatter = FactFormatter.new(user_query, fact_collection)
      puts fact_formatter.to_hocon
    end

    def start_threads(searched_facts)
      threads = []

      searched_facts.each do |searched_fact|
        threads << Thread.new do
          fact_class = searched_fact.fact_class
          fact_class.new(searched_fact.filter_tokens).call_the_resolver
        end
      end

      threads
    end

    def join_threads!(threads, searched_facts)
      threads.each do |thread|
        thread.join
        facts = thread.value
        enrich_searched_fact_with_value!(searched_facts, facts)
      end

      searched_facts
    end

    def enrich_searched_fact_with_value!(searched_facts, facts)
      # matched_facts = searched_facts.select { |elem|  facts.select { |fact| fact.name.match(elem.name)}.any?  }
      # matched_facts.each do |matched_fact|
      #   matched_fact.value = facts[matched_fact.name].value
      # end

      searched_facts.each do |searched_fact|
        if searched_fact.name.end_with?('regexfact')
          searched_fact.name = searched_fact.name[0..-10]
        end

        matched_facts = facts.select { |fact| fact.name.match(searched_fact.name) }
        if matched_facts.any?
          searched_fact.value = matched_facts.first.value
          # should create a searched_fact for each fact
          if searched_fact.name.end_with?('_')
            searched_fact.name = matched_facts.first.name
          end
        end
      end
    end
  end
end
