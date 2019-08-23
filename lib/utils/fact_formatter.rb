# frozen_string_literal: true

module Facter
  class FactFormatter
    def initialize(searched_facts, fact_collection)
      @searched_facts = searched_facts
      @fact_collection = fact_collection
    end

    def to_j
      JSON.pretty_generate(@fact_collection)
    end

    def to_h
      printable_hash = to_printable

      if @searched_facts.length == 1
        printable_hash.values[0]
      else
        printable_hash = sort_by_key(printable_hash, true)

        hash_to_hocon(printable_hash)
      end
    end

    private

    def hash_to_hocon(hash)
      pretty_json = JSON.pretty_generate(hash)
      pretty_json.gsub!(':', ' =>')
      pretty_json = pretty_json[1..-2]
      pretty_json.gsub!(/\"(.*)\"\ =>/, '\1 =>')

      pretty_json.split('\n').map! { |line| line.gsub(/^  /, '') }
    end

    # Sort nested hash.
    def sort_by_key(hash, recursive = false, &block)
      hash.keys.sort(&block).each_with_object({}) do |key, seed|
        seed[key] = hash[key]
        seed[key] = sort_by_key(seed[key], true, &block) if recursive && seed[key].is_a?(Hash)

        seed
      end
    end

    # If the user did not provide any query, return the fact collection unchanged.
    # If the user provided some search query,
    # return a hash containing search query as key and query result as value.
    def to_printable
      if @searched_facts.length.zero?
        @fact_collection
      else
        facts_to_display = {}
        @searched_facts.each do |searched_fact|
          printable_value = @fact_collection.dig(*searched_fact.split('.'))
          facts_to_display.merge!(searched_fact => printable_value)
        end
        facts_to_display
      end
    end
  end
end
