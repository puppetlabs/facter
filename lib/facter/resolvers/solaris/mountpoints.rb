# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class Mountpoints < BaseResolver
        include Facter::FilesystemHelper
        @semaphore = Mutex.new
        @fact_list ||= {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_mounts(fact_name) }
          end

          def root_device
            cmdline = Util::FileHelper.safe_read('/proc/cmdline')
            match = cmdline.match(/root=([^\s]+)/)
            match&.captures&.first
          end

          def compute_device(device)
            # If the "root" device, lookup the actual device from the kernel options
            # This is done because not all systems symlink /dev/root
            device = root_device if device == '/dev/root'
            device
          end

          def read_mounts(fact_name) # rubocop:disable Metrics/AbcSize
            mounts = []
            FilesystemHelper.read_mountpoints.each do |fs|
              device = compute_device(fs.name)
              filesystem = fs.mount_type
              path = fs.mount_point
              options = fs.options.split(',').map(&:strip)

              stats = FilesystemHelper.read_mountpoint_stats(path)
              size_bytes = stats.bytes_total.abs
              available_bytes = stats.bytes_available.abs

              used_bytes = stats.bytes_used.abs
              total_bytes = used_bytes + available_bytes
              capacity = FilesystemHelper.compute_capacity(used_bytes, total_bytes)

              size = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(size_bytes)
              available = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(available_bytes)
              used = Facter::FactsUtils::UnitConverter.bytes_to_human_readable(used_bytes)

              mounts << Hash[FilesystemHelper::MOUNT_KEYS.zip(FilesystemHelper::MOUNT_KEYS
                .map { |v| binding.local_variable_get(v) })]
            end
            @fact_list[:mountpoints] = mounts
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
