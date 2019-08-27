# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/utils/file_loader"

module Facter
  def self.new(args)
    Facter::Base.new(args)
  end

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
      threads = []

      searched_facts.each do |searched_fact|
        threads << Thread.new do
          fact_class = searched_fact.fact_class
          fact_class.new(searched_fact.filter_tokens).call_the_resolver
        end
      end

      join_threads!(threads, searched_facts)

      FactFilter.new.filter_facts!(searched_facts)
      resolved_facts = build_fact_collection(searched_facts)

      fact_formatter = FactFormatter.new(user_query, resolved_facts)
      puts fact_formatter.to_hocon
    end

    def join_threads!(threads, searched_facts)
      # fact_collection = FactCollection.new

      threads.each do |thread|
        thread.join
        fact = thread.value
        enrich_searched_fact_with_value!(searched_facts, fact)
      end

      searched_facts
    end

    def enrich_searched_fact_with_value!(searched_facts, fact)
      matched_fact = searched_facts.select { |elem| elem.name == fact.name }
      matched_fact.first.value = fact.value
    end

    def build_fact_collection(searched_facts)
      fact_collection = FactCollection.new

      searched_facts.each do |fact|
        fact_collection.bury(*fact.name.split('.') + fact.filter_tokens << fact.value)
      end

      fact_collection
    end
  end
end
