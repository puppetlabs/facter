# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Memory < BaseResolver
        # :hardware
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { execute_svmon(fact_name) }
          end

          def execute_svmon(fact_name)
            result = Facter::Core::Execution.execute('svmon', logger: log)
            return if result.empty?

            pagesize = call_pagesize.to_i
            return if pagesize.zero?

            @fact_list[:system] = @fact_list[:swap] = {}

            result.each_line do |line|
              @fact_list[:system] = populate_system(line, pagesize) if line.include?('memory')
              @fact_list[:swap] = populate_swap(line, pagesize) if line =~ /pg\sspace/
            end

            @fact_list[fact_name]
          end

          def call_pagesize
            Facter::Core::Execution.execute('pagesize', logger: log).strip
          end

          def populate_system(content, pagesize)
            content = content.split(' ')

            total = content[1].to_i * pagesize
            used = content[2].to_i * pagesize

            { available_bytes: content[3].to_i * pagesize,
              total_bytes: total,
              used_bytes: used,
              capacity: FilesystemHelper.compute_capacity(used, total) }
          end

          def populate_swap(content, pagesize)
            content = content.split(' ')

            total = content[2].to_i * pagesize
            used = content[3].to_i * pagesize

            { available_bytes: total - used,
              total_bytes: total,
              used_bytes: used,
              capacity: FilesystemHelper.compute_capacity(used, total) }
          end
        end
      end
    end
  end
end
