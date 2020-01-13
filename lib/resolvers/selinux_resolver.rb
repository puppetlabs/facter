# frozen_string_literal: true

module Facter
  module Resolvers
    class SELinux < BaseResolver
      # :name
      # :version
      # :codename

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_lsb_release_file(fact_name) }
        end

        def read_lsb_release_file(fact_name)
          output, _s = Open3.capture2('cat /proc/self/mounts')
          @fact_list[:enabled] = false

          output.each_line do |line|
            next unless line.match(/selinuxfs/)

            @fact_list[:enabled] = true
            @fact_list[:mountpoint] = line
            break
          end

          @fact_list[fact_name]
        end
      end
    end
  end
end
