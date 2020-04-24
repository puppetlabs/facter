# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Processors < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { collect_kstat_info(fact_name) }
          end

          def collect_kstat_info(fact_name)
            return unless File.executable?('/usr/bin/kstat')

            kstat_output, stderr, status = Open3.capture3('/usr/bin/kstat -m cpu_info')
            unless status.to_i.zero?
              @log.debug("Command /usr/bin/kstat failed with error message: #{stderr}")
              return
            end

            parse_output(kstat_output.chomp)
            @fact_list[fact_name]
          end

          def parse_output(output)
            @fact_list[:logical_count] = output.scan(/module/).size
            @fact_list[:physical_count] = output.scan(/chip_id .*/).uniq.size
            @fact_list[:speed] = output.scan(/current_clock_Hz .*/).first.gsub(/[a-zA-z\s]+/, '').to_i
            @fact_list[:models] = output.scan(/brand .*/).map { |elem| elem.gsub(/brand(\s+)/, '') }
          end
        end
      end
    end
  end
end
