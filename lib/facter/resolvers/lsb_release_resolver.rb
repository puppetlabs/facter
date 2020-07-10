# frozen_string_literal: true

module Facter
  module Resolvers
    class LsbRelease < BaseResolver
      # :lsb_version
      # :distributor_id
      # :description
      # :release
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_facts(fact_name) }
        end

        def retrieve_facts(fact_name)
          lsb_release_installed? if @fact_list[:lsb_release_installed].nil?
          read_lsb_release_file if @fact_list[:lsb_release_installed]
          @fact_list[fact_name]
        end

        def lsb_release_installed?
          output = Facter::Core::Execution.execute('which lsb_release', logger: log)
          @fact_list[:lsb_release_installed] = !output.empty?
        end

        def read_lsb_release_file
          output = Facter::Core::Execution.execute('lsb_release -a', logger: log)
          build_fact_list(output)
        end

        def build_fact_list(info)
          release_info = info.delete("\t").split("\n").map { |e| e.split(':', 2) }

          result = Hash[*release_info.flatten]
          result.each { |k, v| @fact_list[k.downcase.gsub(/\s/, '_').to_sym] = v }

          @fact_list[:identifier] = @fact_list[:distributor_id]
        end
      end
    end
  end
end
