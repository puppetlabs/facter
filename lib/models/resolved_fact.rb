# frozen_string_literal: true

module Facter
  class ResolvedFact
    attr_accessor :name, :value, :user_query, :filter_tokens

    def initialize(name, value = '')
      @name = name
      @value = value
    end
  end
end
