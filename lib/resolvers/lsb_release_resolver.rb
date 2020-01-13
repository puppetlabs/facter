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
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_lsb_release_file(fact_name) }
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
