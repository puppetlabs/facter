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
      @log = Facter::Log.new(self)
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
          output, stderr, _status = Open3.capture3('which lsb_release')
          @log.debug(stderr) unless stderr.empty?
          @fact_list[:lsb_release_installed] = !output.empty?
        end

        def read_lsb_release_file
          output, stderr, _status = Open3.capture3('lsb_release -a')
          @log.debug(stderr) unless stderr.empty?
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
