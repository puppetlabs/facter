# frozen_string_literal: true

module Facter
  module Resolvers
    class OsRelease < BaseResolver
      # :pretty_name
      # :name
      # :version_id
      # :version
      # :id
      # :id_like
      # :ansi_color
      # :home_url
      # :support_url
      # :bug_report_url

      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_os_release_file(fact_name) }
        end

        def read_os_release_file(fact_name)
          output = Facter::Util::FileHelper.safe_readlines('/etc/os-release')
          return @fact_list[:name] = nil if output.empty?

          pairs = []

          output.each do |line|
            pairs << line.strip.delete('"').split('=', 2)
          end

          fill_fact_list(pairs)
          process_name
          pad_version_id
          normalize_opensuse_identifier

          @fact_list[fact_name]
        end

        def fill_fact_list(pairs)
          result = Hash[*pairs.flatten]
          result.each { |k, v| @fact_list[k.downcase.to_sym] = v }

          @fact_list[:identifier] = @fact_list[:id]
        end

        def pad_version_id
          @fact_list[:version_id] = "#{@fact_list[:version_id]}.0" unless @fact_list[:version_id] =~ /\./
        end

        def process_name
          return unless @fact_list[:name]

          @fact_list[:name] = if @fact_list[:name].downcase.start_with?('red', 'oracle')
                                @fact_list[:name].split(' ')[0..1].join
                              else
                                @fact_list[:name].split(' ')[0].strip
                              end
        end

        def normalize_opensuse_identifier
          @fact_list[:identifier] = 'opensuse' if @fact_list[:identifier] =~ /opensuse/i
        end
      end
    end
  end
end
