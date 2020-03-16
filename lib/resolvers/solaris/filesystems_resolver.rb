# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Filesystem < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_sysdef_file(fact_name) }
          end

          def read_sysdef_file(fact_name)
            return unless File.readable?('/usr/sbin/sysdef')

            file_content, _status = Open3.capture2('/usr/sbin/sysdef')
            files = file_content.split("\n").map do |line|
              line.split('/').last if line =~ /^fs\.*/
            end

            @fact_list[:file_systems] = files.compact.sort.join(',')
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
