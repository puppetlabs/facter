# frozen_string_literal: true

module Facter
  module Resolvers
    class RedHatRelease < BaseResolver
      # :name
      # :version
      # :codename

      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_redhat_release(fact_name) }
        end

        def read_redhat_release(fact_name)
          output = Util::FileHelper.safe_read('/etc/redhat-release', nil)
          return @fact_list[fact_name] = nil if output.nil?

          build_fact_list(output)

          @fact_list[fact_name]
        end

        def build_fact_list(output)
          output_strings = output.split('release')
          output_strings.map!(&:strip)
          version_codename = output_strings[1].split(' ')

          @fact_list[:name] = name(output_strings[0])
          @fact_list[:version] = version_codename[0]&.strip

          codename = version_codename[1]&.strip
          @fact_list[:codename] = codename ? codename.gsub(/[()]/, '') : nil

          @fact_list[:identifier] = identifier(@fact_list[:name])
        end

        def name(name)
          name.strip.split(' ')[0..1].join
        end

        def identifier(name)
          identifier = name.strip.downcase
          identifier = 'rhel' if @fact_list[:name].strip.casecmp('Red Hat Enterprise Linux')

          identifier
        end
      end
    end
  end
end
