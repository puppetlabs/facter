# frozen_string_literal: true

module Facter
  module Resolvers
    class LsbRelease < BaseResolver
      # :distributor_id
      # :description
      # :release
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_lsb_release_file(fact_name)
          end
        end

        def read_lsb_release_file(fact_name)
          output, _status = Open3.capture2('lsb_release -a')
          release_info = output.delete("\t").split("\n").map { |e| e.split(':') }

          result = Hash[*release_info.flatten]
          result.each { |k, v| @fact_list[k.downcase.gsub(/\s/, '_').to_sym] = v }

          @fact_list[:identifier] = @fact_list[:distributor_id]
          @fact_list[fact_name]
        end
      end
    end
  end
end
