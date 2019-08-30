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
    def initialize
      os = OsDetector.detect_family
      @loaded_facts_hash = Facter::FactLoader.load(os)
    end

    def resolve_facts(user_query)
      searched_facts = Facter::QueryParser.parse(user_query, @loaded_facts_hash)

      threads = start_threads(searched_facts)
      join_threads!(threads, searched_facts)

      FactFilter.new.filter_facts!(searched_facts)
      fact_collection = FactCollection.new.build_fact_collection!(searched_facts)

      fact_collection
    end

    private

    def start_threads(searched_facts)
      threads = []

      searched_facts.each do |searched_fact|
        threads << Thread.new do
          fact_class = searched_fact.fact_class
          fact_class.new.call_the_resolver
        end
      end

      threads
    end

    def join_threads!(threads, searched_facts)
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
  end
end
