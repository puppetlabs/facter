# frozen_string_literal: true

module Facter
  module Resolvers
    class SolarisRelease < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      @os_version_regex_patterns = ['Solaris \d+ \d+/\d+ s(\d+)[sx]?_u(\d+)wos_',
                                    'Solaris (\d+)[.](\d+)', 'Solaris (\d+)']
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || build_release_facts(fact_name)
          end
        end

        private

        def build_release_facts(fact_name)
          result = read_os_release_file
          return unless result

          @os_version_regex_patterns.each do |os_version_regex|
            major, minor = search_for_os_version(/#{os_version_regex}/, result)
            next unless major || minor

            @fact_list[:major] = major
            @fact_list[:minor] = minor
            @fact_list[:full] = major == '10' ? major + '_u' + minor : major + '.' + minor
            break
          end
          @fact_list[fact_name]
        end

        def search_for_os_version(regex_pattern, text)
          result = text.match(regex_pattern)
          major, minor = result.captures if result
          minor = regex_pattern == /Solaris (\d+)/ ? '0' : minor
          return [major, minor] if major && minor
        end

        def read_os_release_file
          output, status = Open3.capture2('cat /etc/release')
          if !status.to_s.include?('exit 0') || output.empty?
            @log.error('Could not build release fact because of missing or empty file /etc/release')
            return
          end
          output
        end
      end
    end
  end
end
