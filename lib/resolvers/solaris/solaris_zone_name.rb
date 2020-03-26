# frozen_string_literal: true

module Facter
  module Resolvers
    class SolarisZoneName < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { build_current_zone_name_fact(fact_name) }
        end

        def build_current_zone_name_fact(fact_name)
          return unless File.executable?('/bin/zonename')

          zone_name_output, status = Open3.capture2('/bin/zonename')
          unless status.to_s.include?('exit 0')
            @log.debug("Command #{command} returned status: #{status}")
            return
          end
          if zone_name_output.empty?
            @log.debug("Command #{command} returned an empty result")
            return
          end
          @fact_list[:current_zone_name] = zone_name_output.chomp
          @fact_list[fact_name]
        end
      end
    end
  end
end
