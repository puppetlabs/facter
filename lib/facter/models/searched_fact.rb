# frozen_string_literal: true

module Facter
  class SearchedFact
    attr_reader :name, :fact_class, :filter_tokens, :user_query, :type
    attr_accessor :file

    def initialize(fact_name, fact_class, filter_tokens, user_query, type)
      @name = fact_name
      @fact_class = fact_class
      @filter_tokens = filter_tokens
      @user_query = user_query
      @type = type
    end
  end
end
