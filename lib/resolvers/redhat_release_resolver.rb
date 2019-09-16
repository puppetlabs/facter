# frozen_string_literal: true

module Facter
  module Resolver
    class RedHatReleaseResolver < BaseResolver
      # :name
      # :version
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]

            return result unless result.nil?

            output, _status = Open3.capture2('cat /etc/redhat-release')

            build_fact_list(output)

            return @fact_list[fact_name]
          end
        end

        private

        def build_fact_list(output)
          output_strings = output.split('release')
          output_strings.map!(&:strip)
          version_codename = output_strings[1].split(' ')

          @fact_list[:name] = output_strings[0].strip
          @fact_list[:version] = version_codename[0].strip
          codename = version_codename[1].strip
          @fact_list[:codename] = codename.gsub(/[()]/, '')

          @fact_list[:identifier] = identifier(@fact_list[:name])
        end

        def identifier(name)
          identifier = name.strip.downcase
          identifier = 'rhel' if @fact_list[:name].strip == 'Red Hat Enterprise Linux'

          identifier
        end
      end
    end
  end
end
