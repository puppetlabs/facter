# frozen_string_literal: true

module Facter
  module Resolvers
    class SwVers < BaseResolver
      # :productname
      # :productversion
      # :buildversion
      #
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || software_version_system_call(fact_name)
          end
        end

        def software_version_system_call(fact_name)
          output, _status = Open3.capture2('sw_vers')
          release_info = output.delete("\t").split("\n").map { |e| e.split(':') }
          result = Hash[*release_info.flatten]
          result.each { |k, v| @fact_list[k.downcase.to_sym] = v }
          @fact_list[fact_name]
        end
      end
    end
  end
end
