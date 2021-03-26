# frozen_string_literal: true

module Facter
  class SearchedFact
    extend Forwardable
    def_delegators :@fact_attributes, :user_query, :filter_tokens, :structured, :file
    def_delegators :@fact_attributes, :user_query=, :filter_tokens=

    attr_reader :name, :klass, :type

    def initialize(name, klass, type, fact_attributes)
      @name = name
      @klass = klass
      @type = type
      @fact_attributes = fact_attributes
    end
  end
end
