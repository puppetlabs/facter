# frozen_string_literal: true

module Facter
  class Base
    def initialize(searched_facts)
      fact_list = Facter::FactLoader.load(:linux)
      searched_facts ||= fact_list

      matched_facts = Facter::QueryParser.parse(searched_facts, fact_list)
      resolve_matched_facts(matched_facts.flatten(1))
    end

    def resolve_matched_facts(matched_facts)
      threads = []

      matched_facts.each do |matched_fact|
        threads << Thread.new do
          fact_class = matched_fact.fact_class
          fact_class.new(matched_fact.filter_tokens).call_the_resolver!
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
end
