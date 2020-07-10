# frozen_string_literal: true

module Facter
  module Resolvers
    class Facterversion < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_version_file }
        end

        def read_version_file
          version_file = ::File.join(File.dirname(__FILE__), '../VERSION')
          @fact_list[:facterversion] = ::File.read(version_file).chomp('')
        end
      end
    end
  end
end
