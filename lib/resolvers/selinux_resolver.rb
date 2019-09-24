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
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_lsb_release_file(fact_name)
          end
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
