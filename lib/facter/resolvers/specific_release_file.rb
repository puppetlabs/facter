# frozen_string_literal: true

module Facter
  module Resolvers
    class SpecificReleaseFile < BaseResolver
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

          if options[:regex]
            @fact_list[:release] = output.strip =~ /#{options[:regex]}/ ? Regexp.last_match : nil
            return @fact_list[fact_name]
          end

          @fact_list[:release] = output.strip
          @fact_list[fact_name]
        end
      end
    end
  end
end
