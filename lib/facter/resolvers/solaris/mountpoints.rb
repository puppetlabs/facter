# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Mountpoints < BaseResolver
        include Facter::Util::Resolvers::FilesystemHelper
        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { read_mounts(fact_name) }
          end

          def exclude_auto_home_mounts!
            @mounts.reject! do |mount|
              parent = mount[:path].rpartition('/').first
              @auto_home_paths.include?(parent)
            end
          end

          def read_mounts(fact_name)
            @mounts = []
            @auto_home_paths = []
            begin
              Facter::Util::Resolvers::FilesystemHelper.read_mountpoints&.each do |fs|
                if fs.name == 'auto_home'
                  @auto_home_paths << fs.mount_point
                  next
                end

                next if fs.mount_type == 'autofs'

                mounts = {}
                device = fs.name
                filesystem = fs.mount_type
                path = fs.mount_point
                options = fs.options.split(',').map(&:strip)

                mounts = read_stats(path).tap do |hash|
                  hash[:device] = device
                  hash[:filesystem] = filesystem
                  hash[:path] = path
                  hash[:options] = options if options.any?
                end

                @mounts << Hash[Facter::Util::Resolvers::FilesystemHelper::MOUNT_KEYS
                                .zip(Facter::Util::Resolvers::FilesystemHelper::MOUNT_KEYS
                  .map { |v| mounts[v] })]
              end
            rescue LoadError => e
              @log.debug("Could not read mounts: #{e}")
            end

            exclude_auto_home_mounts!

            @fact_list[:mountpoints] = @mounts
            @fact_list[fact_name]
          end

          def read_stats(path)
            begin
              stats = Facter::Util::Resolvers::FilesystemHelper.read_mountpoint_stats(path)
              size_bytes = stats.bytes_total.abs
              available_bytes = stats.bytes_available.abs
              used_bytes = stats.bytes_used.abs
              total_bytes = used_bytes + available_bytes
            rescue Sys::Filesystem::Error, LoadError
              size_bytes = used_bytes = available_bytes = 0
            end

            {
              size_bytes: size_bytes,
              available_bytes: available_bytes,
              used_bytes: used_bytes,
              total_bytes: total_bytes,
              capacity: Facter::Util::Resolvers::FilesystemHelper.compute_capacity(used_bytes, total_bytes),
              size: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(size_bytes),
              available: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(available_bytes),
              used: Facter::Util::Facts::UnitConverter.bytes_to_human_readable(used_bytes)
            }
          end
        end
      end
    end
  end
end
