# frozen_string_literal: true

module Facter
  module Resolvers
    class ReleaseFromFirstLine < BaseResolver
      # :release

      init_resolver

      class << self
        private

        def post_resolve(fact_name, options)
          @fact_list.fetch(fact_name) { read_release_file(fact_name, options) }
        end

        def read_release_file(fact_name, options)
          release_file = options[:release_file]
          return unless release_file

          output = Facter::Util::FileHelper.safe_read(release_file, nil)
          return @fact_list[fact_name] = nil if output.nil?

          @fact_list[:release] = retrieve_version(output)

          @fact_list[fact_name]
        end

        def retrieve_version(output)
          if output[/(Rawhide)$/]
            'Rawhide'
          elsif output['release']
            output.strip =~ /release (\d[\d.]*)/ ? Regexp.last_match(1) : nil
          else
            output.strip =~ /Amazon Linux (\d+)/ ? Regexp.last_match(1) : nil
          end
        end
      end
    end
  end
end
