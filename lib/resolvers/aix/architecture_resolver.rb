# frozen_string_literal: true

module Facter
  module Resolvers
    class Architecture < BaseResolver
      # :architecture
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_architecture(fact_name) }
        end

        def read_architecture(fact_name)
          odmquery = ODMQuery.new
          odmquery
            .equals('name', 'proc0')
            .equals('attribute', 'type')

          result = odmquery.execute

          return unless result

          result.each_line do |line|
            if line.include?('value')
              @fact_list[:architecture] = line.split('=')[1].strip.delete('\"')
              break
            end
          end

          @fact_list[fact_name]
        end
      end
    end
  end
end
