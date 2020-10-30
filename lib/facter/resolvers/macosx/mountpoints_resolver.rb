# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class Mountpoints < BaseResolver
        include Facter::FilesystemHelper
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_mounts }
          end

          def read_mounts
            mounts = {}

            FilesystemHelper.read_mountpoints.each do |fs|
              device = fs.name
              filesystem = fs.mount_type
              path = fs.mount_point
              options = fs.options.split(',').map(&:strip).map { |o| o == 'rootfs' ? 'root' : o }

              mounts[path] = read_stats(path).tap do |hash|
                hash[:device] = device
                hash[:filesystem] = filesystem
                hash[:options] = options if options.any?
              end
            end

            @fact_list[:mountpoints] = mounts
          end

          def read_stats(path)
            begin
              stats = FilesystemHelper.read_mountpoint_stats(path)
              size_bytes = stats.bytes_total
              available_bytes = stats.bytes_available
              used_bytes = size_bytes - available_bytes
            rescue Sys::Filesystem::Error
              size_bytes = used_bytes = available_bytes = 0
            end

            {
              size_bytes: size_bytes,
              used_bytes: used_bytes,
              available_bytes: available_bytes,
              capacity: FilesystemHelper.compute_capacity(used_bytes, size_bytes),
              size: Facter::FactsUtils::UnitConverter.bytes_to_human_readable(size_bytes),
              available: Facter::FactsUtils::UnitConverter.bytes_to_human_readable(available_bytes),
              used: Facter::FactsUtils::UnitConverter.bytes_to_human_readable(used_bytes)
            }
          end
        end
      end
    end
  end
end
