# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class DockerUptime < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { detect_uptime(fact_name) }
          end

          def detect_uptime(fact_name)
            days, hours, minutes, seconds = extract_uptime_from_docker
            total_seconds = convert_to_seconds(days, hours, minutes, seconds)
            @fact_list = Utils::UptimeHelper.create_uptime_hash(total_seconds)

            @fact_list[fact_name]
          end

          def extract_uptime_from_docker
            # time format [dd-][hh:]mm:ss
            time = Facter::Core::Execution.execute('ps -o etime= -p "1"', logger: log)
            extracted_time = time.split(/[-:]/)

            reversed_time = extracted_time.reverse
            seconds = reversed_time[0].to_i
            minutes = reversed_time[1].to_i
            hours = reversed_time[2].to_i
            days = reversed_time[3].to_i

            [days, hours, minutes, seconds]
          end

          def convert_to_seconds(days, hours, minutes, seconds)
            days * 24 * 3600 + hours * 3600 + minutes * 60 + seconds
          end
        end
      end
    end
  end
end
