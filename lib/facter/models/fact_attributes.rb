# frozen_string_literal: true

module Facter
  class FactAttributes
    attr_accessor :user_query, :filter_tokens, :structured

    def initialize(user_query:, filter_tokens:, structured:)
      @user_query = user_query
      @filter_tokens = filter_tokens
      @structured = structured
    end
  end
end
