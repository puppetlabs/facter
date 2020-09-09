# frozen_string_literal: true

module Facter
  module Resolvers
    class OsLevel < BaseResolver
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_oslevel(fact_name) }
        end

        def read_oslevel(fact_name)
          output = Facter::Core::Execution.execute('/usr/bin/oslevel -s', logger: log)
          @fact_list[:build] = output
          @fact_list[:kernel] = 'AIX'

          @fact_list[fact_name]
        end
      end
    end
  end
end
