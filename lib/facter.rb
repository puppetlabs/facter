# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/utils/file_loader"

module Facter
  class Base
    def initialize(searched_facts)
      os = OsDetector.detect_family
      loaded_facts_hash = Facter::FactLoader.load(os)
      searched_facts = loaded_facts_hash.keys unless searched_facts.any?

      matched_facts = Facter::QueryParser.parse(searched_facts, loaded_facts_hash)
      resolve_matched_facts(matched_facts)
    end

    def resolve_matched_facts(matched_facts)
      threads = []

      matched_facts.each do |matched_fact|
        threads << Thread.new do
          fact_class = matched_fact.fact_class
          fact_class.new.call_the_resolver
        end
      end

      fact_collection = join_threads(threads)

      fact_formatter = FactFormatter.new(fact_collection)
      puts fact_formatter.to_h
    end

    def join_threads(threads)
      fact_collection = FactCollection.new

      threads.each do |t|
        t.join
        fact = t.value
        fact_collection.bury(*fact.name.split('.') << fact.value)
      end

      fact_collection
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
