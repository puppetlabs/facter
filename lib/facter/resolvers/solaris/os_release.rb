# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class OsRelease < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        @os_version_regex_patterns = ['Solaris \d+ \d+/\d+ s(\d+)[sx]?_u(\d+)wos_',
                                      'Solaris (\d+)[.](\d+)', 'Solaris (\d+)']
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { build_release_facts(fact_name) }
          end

          def build_release_facts(fact_name)
            result = Util::FileHelper.safe_read('/etc/release', nil)
            return @fact_list[fact_name] = nil if result.nil?

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
        end
      end
    end
  end
end
