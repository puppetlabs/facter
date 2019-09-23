# frozen_string_literal: true

module Facter
  module Resolvers
    class SolarisOsReleaseResolver < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      @os_version_regex_patterns = ['Solaris \d+ \d+/\d+ s(\d+)[sx]?_u(\d+)wos_',
                                    'Solaris (\d+)[.](\d+)', 'Solaris (\d+)']
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_os_release_file(fact_name)
          end
        end

        private

        def read_os_release_file(fact_name)
          first_line, error = Open3.capture2('cat /etc/release')[0]
          if error
            @log.error('Could not build release fact because of missing file /etc/release')
            return nil
          end
          @os_version_regex_patterns.each do |os_version_regex|
            major, minor = search_for_os_version(/#{os_version_regex}/, first_line)
            next unless major && minor
            @fact_list[:major] = major
            @fact_list[:minor] = minor
            @fact_list[:release] = major == 10 ? major + '_u' + minor : major + '.' + minor
          end
            @fact_list[fact_name]
        end

        def search_for_os_version(regex_pattern, line)
          result = line.match(regex_pattern)
          major, minor = result.captures if result
          return [major, minor] if major && minor
        end
      end
    end
  end
end
