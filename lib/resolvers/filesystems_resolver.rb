# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Filesystems < BaseResolver
        # :systems
        @semaphore = Mutex.new
        @fact_list ||= {}
        @log = Facter::Log.new(self)
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_filesystems(fact_name) }
          end

          def read_filesystems(fact_name)
            output = File.read('/proc/filesystems')
            filesystems = []
            output.each_line do |line|
              tokens = line.split(' ')
              filesystems << tokens if tokens.size == 1
            end
            @fact_list[:systems] = filesystems.sort.join(',')
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
