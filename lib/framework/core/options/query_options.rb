# frozen_string_literal: true

module Facter
  module QueryOptions
    def augment_with_query_options!(user_query)
      @options[:user_query] = true if user_query.any?
    end
  end
end
