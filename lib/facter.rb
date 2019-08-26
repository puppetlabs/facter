# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/utils/file_loader"

module Facter
  class Base
    def initialize(searched_facts)
      os = OsDetector.detect_family
      loaded_facts_hash = Facter::FactLoader.load(os)
      matched_facts = Facter::QueryParser.parse(searched_facts, loaded_facts_hash)
      resolve_matched_facts(searched_facts, matched_facts)
    end

    def resolve_matched_facts(searched_facts, matched_facts)
      threads = []

      matched_facts.each do |matched_fact|
        threads << Thread.new do
          fact_class = matched_fact.fact_class
          fact_class.new(matched_fact.filter_tokens).call_the_resolver
        end
      end

      # fact_collection = join_threads(threads, matched_facts)
      join_threads(threads, matched_facts)
      fact_collection = build_fact_collection(matched_facts)

      fact_formatter = FactFormatter.new(searched_facts, fact_collection)
      puts fact_formatter.to_hocon
    end

    def build_fact_collection(matched_facts)
      fact_collection = FactCollection.new

      matched_facts.each do |fact|
        value = filter_fact(fact)
        fact_collection.bury(*fact.fact_name.split('.') + fact.filter_tokens << value)
      end

      fact_collection
    end

    def filter_fact(fact)
      fact.filter_tokens.any? ? fact.value.dig(*fact.filter_tokens.map(&:to_sym)) : fact.value
    end

    def join_threads(threads, matched_facts)
      # fact_collection = FactCollection.new

      threads.each do |t|
        t.join
        fact = t.value

        matched_fact = matched_facts.select { |elem| elem.fact_name == fact.name }
        matched_fact.first.value = fact.value
        # fact_collection.bury(*fact.name.split('.') << fact.value)
      end

      # fact_collection
      matched_facts
    end
  end

  def self.new(args)
    Facter::Base.new(args)
  end

  def self.to_hash
    Facter::Base.new([])
  end

  def self.value(*args)
    Facter::Base.new(args)
  end
end
