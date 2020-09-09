# frozen_string_literal: true

module Facter
  module Resolvers
    class Path < BaseResolver
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_path_from_env }
        end

        def read_path_from_env
          @fact_list[:path] = ENV['PATH']
        end
      end
    end
  end
end
