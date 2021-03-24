# frozen_string_literal: true

module Facter
  class NullFactAttributes
    attr_accessor :user_query, :filter_tokens, :structured

    def initialize
      @user_query = nil
      @filter_tokens = []
      @structured = false
    end
  end
end
