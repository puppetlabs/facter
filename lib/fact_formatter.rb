# frozen_string_literal: true

module Facter
  class FactFormatter
    def initialize(fact_collection)
      @fact_collection = fact_collection
    end

    def to_j
      @fact_collection.to_json
    end

    def to_h
      @fact_collection.to_s
    end

    def to_pretty_j
      JSON.pretty_generate(@fact_collection)
    end

    def to_pretty_h
      JSON.pretty_generate(@fact_collection).gsub(':', ' =>')
    end
  end
end
