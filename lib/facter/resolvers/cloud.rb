# frozen_string_literal: true

module Facter
  module Resolvers
    class Cloud < BaseResolver
      # cloud_provider

      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { detect_azure(fact_name) }
        end

        def detect_azure(fact_name)
          search_dirs = %w[/var/lib/dhcp /var/lib/NetworkManager]
          search_dirs.each do |path|
            next unless File.directory?(path)

            files = Dir.entries(path)
            files.select! { |filename| filename =~ /^dhclient.*lease.*$/ }
            files.each do |file|
              path = File.join([path, file])
              output = Util::FileHelper.safe_read(path)

              if output.include?('option unknown-245') || output.include?('option 245')
                @fact_list[:cloud_provider] = 'azure'
                return @fact_list[fact_name]
              end
            end
          end
          nil
        end
      end
    end
  end
end
