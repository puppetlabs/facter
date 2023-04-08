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

        def post_resolve(fact_name, _options)
          @fact_list.fetch(fact_name) do
            # If we get here multiple times per run it's probably because
            # someone's asking for a os-release value not present in the file
            # (e.g. VERSION is not a thing on rolling distributions, so this
            # code will always run if the resolver is being asked for :version,
            # because it'll never get cached).
            #
            # Just return early to avoid reparsing the file.
            return unless @fact_list.empty?

            pairs = read_and_parse_os_release_file
            return unless pairs

            fill_fact_list(pairs)

            process_name
            process_version_id
            process_id

            @fact_list[fact_name]
          end
        end

        def read_and_parse_os_release_file
          content = Facter::Util::FileHelper.safe_readlines('/etc/os-release')
          return nil if content.empty?

          pairs = []
          content.each do |line|
            pairs << line.strip.delete('"').split('=', 2)
          end

          pairs
        end

        def fill_fact_list(pairs)
          result = Hash[*pairs.flatten]
          result.each { |k, v| @fact_list[k.downcase.to_sym] = v }
        end

        def process_version_id
          return unless @fact_list[:version_id]

          @fact_list[:version_id] = "#{@fact_list[:version_id]}.0" unless /\./.match?(@fact_list[:version_id])
        end

        def process_id
          return unless @fact_list[:id]

          @fact_list[:id] = 'opensuse' if /opensuse/i.match?(@fact_list[:id])
        end

        def process_name
          return unless @fact_list[:name]

          join_os_name
          capitalize_os_name
          append_linux_to_os_name
        end

        def join_os_name
          os_name = @fact_list[:name]
          @fact_list[:name] = if os_name.downcase.start_with?('red', 'oracle', 'arch', 'manjaro')
                                os_name = os_name.split(' ')[0..1].join
                                os_name
                              elsif os_name.downcase.end_with?('mariner')
                                os_name.split(' ')[-1].strip
                              else
                                os_name.split(' ')[0].strip
                              end
        end

        def capitalize_os_name
          os_name = @fact_list[:name]
          @fact_list[:name] = os_name.capitalize if os_name.downcase.start_with?('arch', 'manjaro')
        end

        def append_linux_to_os_name
          os_name = @fact_list[:name]
          @fact_list[:name] = os_name + 'Linux' if os_name.downcase.start_with?('virtuozzo')
        end
      end
    end
  end
end
