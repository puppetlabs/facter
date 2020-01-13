# frozen_string_literal: true

module Facter
  module Resolvers
    class EosRelease < BaseResolver
      # :name
      # :version
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_eos_release(fact_name) }
        end

        def read_eos_release(fact_name)
          output, _status = Open3.capture2('cat /etc/Eos-release')
          output_strings = output.split(' ')

          @fact_list[:name] = output_strings[0]
          @fact_list[:version] = output_strings[-1]
          @fact_list[fact_name]
        end
      end
    end
  end
end
