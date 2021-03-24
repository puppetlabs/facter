# frozen_string_literal: true

module Facter
  class SearchedFact
    extend Forwardable
    def_delegators :@fact_attributes, :user_query, :filter_tokens, :structured
    def_delegators :@fact_attributes, :user_query=, :filter_tokens=, :structured=

    attr_reader :name, :klass, :type
    attr_accessor :file, :options

    def initialize(name, klass, type, fact_attributes)
      @name = name
      @klass = klass
      @type = type
      @fact_attributes = fact_attributes
    end
  end
end
