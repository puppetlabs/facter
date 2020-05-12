# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      class Mountpoints < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        BLOCK_SIZE = 512

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_mount(fact_name) }
          end

          def read_mount(fact_name)
            @fact_list[:mountpoints] = {}
            output = Facter::Core::Execution.execute('mount', logger: log)
            output.split("\n").map do |line|
              next if line =~ /node|---|procfs|ahafs/

              elem = line.split("\s")

              @fact_list[:mountpoints][elem[1]] = { device: elem[0], filesystem: elem[2],
                                                    options: elem.last.split(',') }
            end

            retrieve_sizes_for_mounts
            @fact_list[fact_name]
          end

          def retrieve_sizes_for_mounts
            output = Facter::Core::Execution.execute('df -P', logger: log)
            output.split("\n").map do |line|
              next if line =~ /Filesystem|-\s+-\s+-/

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
              capacity: FilesystemHelper.compute_capacity(used_bytes, size_bytes),
              available_bytes: available_bytes,
              used_bytes: used_bytes,
              size_bytes: size_bytes,
              available: FactsUtils::UnitConverter.bytes_to_human_readable(available_bytes),
              used: FactsUtils::UnitConverter.bytes_to_human_readable(used_bytes),
              size: FactsUtils::UnitConverter.bytes_to_human_readable(size_bytes)
            )
          end
        end
      end
    end
  end
end
