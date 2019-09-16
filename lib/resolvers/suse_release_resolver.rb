# frozen_string_literal: true

module Facter
  module Resolvers
    class SuseReleaseResolver < BaseResolver
      # :name
      # :version
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]

            return result unless result.nil?

            output, _status = Open3.capture2('cat /etc/SuSE-release')

            output_strings = output.split(' ')

            @fact_list[:name] = output_strings[0]
            @fact_list[:version] = output_strings[1]

            @fact_list[:identifier] = @fact_list[:name].downcase

            return @fact_list[fact_name]
          end
        end
      end
    end
  end
end
