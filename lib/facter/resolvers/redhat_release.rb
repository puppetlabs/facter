# frozen_string_literal: true

module Facter
  module Resolvers
    class RedHatRelease < BaseResolver
      # :name
      # :version
      # :codename
      # :description
      # :distributor_id

      init_resolver

      class << self
        private

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) { read_redhat_release(fact_name) }
        end

        def read_redhat_release(fact_name)
          output = Facter::Util::FileHelper.safe_read('/etc/redhat-release', nil)
          return @fact_list[fact_name] = nil if output.nil?

          build_fact_list(output)

          @fact_list[fact_name]
        end

        def build_fact_list(output)
          @fact_list[:description] = output.strip
          output_strings = output.split('release')
          output_strings.map!(&:strip)

          @fact_list[:codename] = codename(output)
          @fact_list[:distributor_id] = distributor_id(output_strings[0])
          @fact_list[:name] = release_name(output_strings[0])
          @fact_list[:version] = version(output_strings)
          @fact_list[:id] = id(@fact_list[:name])
        end

        def release_name(value)
          value.split.reject { |el| el.casecmp('linux').zero? }[0..1].join
        end

        def id(value)
          id = value.downcase
          id = 'rhel' if @fact_list[:name].casecmp('Red Hat Enterprise Linux')

          id
        end

        def codename(value)
          matched_data = value.match(/.*release.*(\(.*\)).*/)
          return unless matched_data

          codename = (matched_data[1] || '').gsub(/\(|\)/, '')
          codename.empty? ? nil : codename
        end

        def version(value)
          value[1].split.first
        end

        def distributor_id(value)
          value.split.reject { |el| el.casecmp('linux').zero? }.join
        end
      end
    end
  end
end
