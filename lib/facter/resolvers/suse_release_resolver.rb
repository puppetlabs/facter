# frozen_string_literal: true

module Facter
  module Resolvers
    class SuseRelease < BaseResolver
      # :name
      # :version
      # :codename

      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_suse_release(fact_name) }
        end

        def read_suse_release(fact_name)
          output = Facter::Util::FileHelper.safe_read('/etc/SuSE-release', nil)
          return @fact_list[fact_name] = nil if output.nil?

          output_strings = output.split(' ')

          @fact_list[:name] = output_strings[0]
          @fact_list[:version] = output_strings[1]
          @fact_list[:identifier] = @fact_list[:name].downcase

          @fact_list[fact_name]
        end
      end
    end
  end
end
