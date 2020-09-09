# frozen_string_literal: true

module Facter
  module Resolvers
    class Hardware < BaseResolver
      # :hardware
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_hardware(fact_name) }
        end

        def read_hardware(fact_name)
          require_relative 'utils/odm_query'
          odmquery = Facter::ODMQuery.new
          odmquery
            .equals('name', 'sys0')
            .equals('attribute', 'modelname')

          result = odmquery.execute

          return unless result

          result.each_line do |line|
            if line.include?('value')
              @fact_list[:hardware] = line.split('=')[1].strip.delete('\"')
              break
            end
          end

          @fact_list[fact_name]
        end
      end
    end
  end
end
