# frozen_string_literal: true

module Facter
  class FactFormater
    def initialize(fact_collection)
      @fact_collection = fact_collection
    end

    def to_j
      @fact_collection.to_json
    end

    def to_h
      @fact_collection.to_s
    end
  end
end
