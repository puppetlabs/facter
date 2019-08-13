# frozen_string_literal: true

module Facter
  class LoadedFact
    attr_accessor :fact_name, :fact_class, :filter_tokens

    def initialize(fact_name = '', fact_class = '', filter_tokens = '')
      @fact_name = fact_name
      @fact_class = fact_class
      @filter_tokens = filter_tokens
    end
  end
end
