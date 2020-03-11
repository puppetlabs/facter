# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Filesystem < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_vtf_file(fact_name) }
          end

          def read_vtf_file(fact_name)
            return unless File.readable?('/etc/vfs')

            file_content = File.readlines('/etc/vfs').map do |line|
              next if line =~ /#|%/ # skip lines that are comments or defaultvfs line

              line.split(' ').first
            end

            @fact_list[:file_systems] = file_content.compact.sort.join(',')
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
