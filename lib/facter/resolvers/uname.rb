# frozen_string_literal: true

module Facter
  module Resolvers
    class Uname < BaseResolver
      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { uname_system_call(fact_name) }
        end

        def uname_system_call(fact_name)
          output = Facter::Core::Execution.execute('uname -m &&
            uname -n &&
            uname -p &&
            uname -r &&
            uname -s &&
            uname -v', logger: log)

          build_fact_list(output)

          @fact_list[fact_name]
        end

        def build_fact_list(output)
          uname_results = output.split("\n")

          if !uname_results.empty?
            @fact_list[:machine],
            @fact_list[:nodename],
            @fact_list[:processor],
            @fact_list[:kernelrelease],
            @fact_list[:kernelname],
            @fact_list[:kernelversion] = uname_results.map(&:strip)
          else
            log.warn('Request to uname returned no output. Uname related facts are not populated.')
          end
        end
      end
    end
  end
end
