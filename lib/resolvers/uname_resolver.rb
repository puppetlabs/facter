# frozen_string_literal: true

module Facter
  module Resolver
    class UnameResolver < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            result || uname_system_call(fact_name)
          end
        end

        def uname_system_call(fact_name)
          output, _status = Open3.capture2('uname -m &&
            uname -n &&
            uname -p &&
            uname -r &&
            uname -s &&
            uname -v')

          build_fact_list(output)

          @fact_list[fact_name]
        end

        private

        def build_fact_list(output)
          uname_results = output.split("\n")

          @fact_list[:machine] = uname_results[0].strip
          @fact_list[:nodename] = uname_results[1].strip
          @fact_list[:processor] = uname_results[2].strip
          @fact_list[:kernelrelease] = uname_results[3].strip
          @fact_list[:kernelname] = uname_results[4].strip
          @fact_list[:kernelversion] = uname_results[5].strip
        end
      end
    end
  end
end
