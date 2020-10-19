# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Zone < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { build_zone_fact(fact_name) }
          end

          def build_zone_fact(fact_name)
            command = '/usr/sbin/zoneadm list -cp'
            zone_adm_output = Facter::Core::Execution.execute(command, logger: log)

            if zone_adm_output.empty?
              log.debug("Command #{command} returned an empty result")
              return
            end
            @fact_list[:zone] = create_zone_facts(zone_adm_output)

            @fact_list[fact_name]
          end

          def create_zone_facts(zones_result)
            zones_fact = []
            zones_result.each_line do |zone_line|
              id, name, status, path, uuid, brand, ip_type = zone_line.split(':')
              zones_fact << {
                brand: brand,
                id: id,
                iptype: ip_type.chomp,
                name: name,
                uuid: uuid,
                status: status,
                path: path

              }
            end
            zones_fact
          end
        end
      end
    end
  end
end
