# frozen_string_literal: true

module Facter
  module Resolvers
    class Architecture < BaseResolver
      # :architecture
      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_architecture(fact_name) }
        end

        def read_architecture(fact_name)
          require 'facter/util/aix/odm_query'

          proc_number = read_proc
          odmquery = Facter::Util::Aix::ODMQuery.new
          odmquery
            .equals('name', proc_number)
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

        def read_proc
          odmquery = Facter::Util::Aix::ODMQuery.new
          odmquery
            .equals('PdDvLn', 'processor/sys/proc_rspc')
            .equals('status', '1')

          result = odmquery.execute
          result.each_line do |line|
            return line.split('=')[1].strip.delete('\"') if line.include?('name')
          end
        end
      end
    end
  end
end
