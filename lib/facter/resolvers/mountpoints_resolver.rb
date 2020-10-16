# frozen_string_literal: true

module Facter
  module Resolvers
    class Mountpoints < BaseResolver
      include Facter::FilesystemHelper
      @fact_list ||= {}
      @log = Facter::Log.new(self)
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_mounts(fact_name) }
        end

        def root_device
          cmdline = Util::FileHelper.safe_read('/proc/cmdline')
          match = cmdline.match(/root=([^\s]+)/)
          root = match&.captures&.first

          if !root.nil? && root.include?('=')
            # We are dealing with the PARTUUID of the partition. Need to extract partition path.
            root_partition_path = convert_partuuid_to_path(root)
            root = root_partition_path unless root_partition_path.nil?
          end
          root
        end

        def convert_partuuid_to_path(root)
          blkid_content = Facter::Core::Execution.execute('blkid', logger: log)
          partuuid = root.split('=').last
          match = blkid_content.match(/(.+)#{partuuid}/)
          match&.captures&.first&.split(':')&.first
        end

        def compute_device(device)
          # If the "root" device, lookup the actual device from the kernel options
          # This is done because not all systems symlink /dev/root
          device = root_device if device == '/dev/root'
          device
        end

        def read_mounts(fact_name)
          mounts = []
          FilesystemHelper.read_mountpoints.each do |file_system|
            mount = {}
            get_mount_data(file_system, mount)

            next if mount[:path] =~ %r{^/(proc|sys)} && mount[:filesystem] != 'tmpfs' || mount[:filesystem] == 'autofs'

            get_mount_sizes(mount)
            mounts << mount
          end

          @fact_list[:mountpoints] = mounts
          @fact_list[fact_name]
        end

        def get_mount_data(file_system, mount)
          mount[:device] = compute_device(file_system.name)
          mount[:filesystem] = file_system.mount_type
          mount[:path] = file_system.mount_point
          mount[:options] = file_system.options.split(',').map(&:strip)
        end

        def get_mount_sizes(mount)
          stats = FilesystemHelper.read_mountpoint_stats(mount[:path])

          get_bytes_data(mount, stats)

          total_bytes = mount[:used_bytes] + mount[:available_bytes]
          mount[:capacity] = FilesystemHelper.compute_capacity(mount[:used_bytes], total_bytes)

          mount[:size] = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(mount[:size_bytes])
          mount[:available] = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(mount[:available_bytes])
          mount[:used] = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(mount[:used_bytes])
        end

        def get_bytes_data(mount, stats)
          mount[:size_bytes] = stats.bytes_total.abs
          mount[:available_bytes] = stats.bytes_available.abs
          mount[:used_bytes] = stats.bytes_used.abs
        end
      end
    end
  end
end
