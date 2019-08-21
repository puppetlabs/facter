# frozen_string_literal: true

module Facter
  class LoadedFact
    attr_accessor :fact_name, :fact_class, :filter_tokens, :value, :user_query

    def initialize(fact_name = '', fact_class = '', filter_tokens = '', value = '', user_query = '')
      @fact_name = fact_name
      @fact_class = fact_class
      @filter_tokens = filter_tokens
      @value = value
      @user_query = user_query
    end
  end
end
