# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Mountpoints < BaseResolver
        init_resolver

        BLOCK_SIZE = 512

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_mount(fact_name) }
          end

          def read_mount(fact_name)
            @fact_list[:mountpoints] = {}
            output = Facter::Core::Execution.execute('mount', logger: log)
            output.split("\n").drop(2).map do |line|
              next if /procfs|ahafs/.match?(line)

              add_mount_points_fact(line)
            end

            retrieve_sizes_for_mounts
            @fact_list[fact_name]
          end

          def add_mount_points_fact(line)
            elem = line.split("\s")

            elem.shift unless line[0] == ' '

            @fact_list[:mountpoints][elem[1]] = { device: elem[0], filesystem: elem[2],
                                                  options: elem.last.include?(':') ? [] : elem.last.split(',') }
          end

          def retrieve_sizes_for_mounts
            output = Facter::Core::Execution.execute('df -P', logger: log)
            output.split("\n").drop(1).map do |line|
              next if /-\s+-\s+-/.match?(line)

              mount_info = line.split("\s")
              mount_info[3] = translate_to_bytes(mount_info[3])
              mount_info[2] = translate_to_bytes(mount_info[2])
              mount_info[1] = translate_to_bytes(mount_info[1])
              compute_sizes(mount_info)
            end
          end

          def translate_to_bytes(strin_size)
            strin_size.to_i * BLOCK_SIZE
          end

          def compute_sizes(info)
            available_bytes = info[3]
            used_bytes = info[2]
            size_bytes = info[1]
            @fact_list[:mountpoints][info.last].merge!(
              capacity: Facter::Util::Resolvers::FilesystemHelper.compute_capacity(used_bytes, size_bytes),
              available_bytes: available_bytes,
              used_bytes: used_bytes,
              size_bytes: size_bytes,
              available: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(available_bytes),
              used: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(used_bytes),
              size: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(size_bytes)
            )
          end
        end
      end
    end
  end
end
