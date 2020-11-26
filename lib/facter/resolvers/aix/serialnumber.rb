# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Serialnumber < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_serialnumber(fact_name) }
          end

          def read_serialnumber(fact_name)
            odmquery = Facter::Util::Aix::ODMQuery.new
            odmquery
              .equals('name', 'sys0')
              .equals('attribute', 'systemid')
            result = odmquery.execute

            result.each_line do |line|
              if line.include?('value')
                @fact_list[:serialnumber] = line.split('=')[1].strip.delete('\"')[6..-1]
                break
              end
            end

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
