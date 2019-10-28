# frozen_string_literal: true

module Facter
  module Resolvers
    class SolarisZone < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || build_zone_fact(fact_name)
          end
        end

        private

        def build_zone_fact(fact_name)
          zone_adm_output, status = Open3.capture2('/usr/sbin/zoneadm list -cp')
          unless status.to_s.include?('exit 0')
            @log.debug("Command #{command} returned status: #{status}")
            return
          end
          if zone_adm_output.empty?
            @log.debug("Command #{command} returned an empty result")
            return
          end
          @fact_list[:zone] = create_zone_facts(zone_adm_output)

          @fact_list[fact_name]
        end

        def create_zone_facts(zones_result)
          zones_fact = []
          zones_result.each_line do |zone_line|
            id, name, status, path, uuid, brand, ip_type = zone_line.split(':')
            zone_fact = {
              brand: brand,
              id: id,
              ip_type: ip_type.chomp,
              name: name,
              uuid: uuid,
              status: status,
              path: path

            }
            zones_fact << zone_fact
          end
          zones_fact
        end
      end
    end
  end
end
