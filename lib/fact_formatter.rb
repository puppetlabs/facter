# frozen_string_literal: true

module Facter
  class FactFormatter
    def initialize(fact_collection)
      @fact_collection = fact_collection
    end

    def to_j
      JSON.pretty_generate(@fact_collection)
    end

    def to_h
      JSON.pretty_generate(@fact_collection).gsub(':', ' =>')
    end
  end
end
