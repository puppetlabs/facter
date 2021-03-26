# frozen_string_literal: true

module Facter
  class FactAttributes
    attr_accessor :user_query, :filter_tokens, :structured, :file

    def initialize(user_query:, filter_tokens:, structured:, file: nil)
      @user_query = user_query
      @filter_tokens = filter_tokens
      @structured = structured
      @file = file
    end
  end
end
