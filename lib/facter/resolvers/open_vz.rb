# frozen_string_literal: true

module Facter
  module Resolvers
    class OpenVz < BaseResolver
      # build

      init_resolver

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { check_proc_vz(fact_name) }
        end

        def check_proc_vz(fact_name)
          return if !Dir.exist?('/proc/vz') || File.file?('/proc/lve/list') || Dir.entries('/proc/vz').count.equal?(2)

          @fact_list[:vm] = read_proc_status
          @fact_list[fact_name]
        end

        def read_proc_status
          proc_status_content = Facter::Util::FileHelper.safe_readlines('/proc/self/status', nil)
          return unless proc_status_content

          proc_status_content.each do |line|
            parts = line.split("\s")
            next unless parts.size.equal?(2)

            next unless /^envID:/ =~ parts[0]

            @fact_list[:id] = parts[1]

            return 'openvzhn' if parts[1] == '0'

            return 'openvzve'
          end
        end
      end
    end
  end
end
