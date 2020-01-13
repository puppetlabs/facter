# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Mountpoints < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        @log = Facter::Log.new(self)
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_mounts }
          end

          MOUNT_KEYS = %i[device filesystem path options
                          available available_bytes size
                          size_bytes used used_bytes capacity].freeze

          def root_device
            cmdline = File.read('/proc/cmdline')
            match = cmdline.match(/root=([^\s]+)/)
            match&.captures&.first
          end

          def compute_capacity(used, total)
            if used == total
              '100%'
            elsif used.positive?
              "#{format('%.2f', 100.0 * used.to_f / total.to_f)}%"
            else
              '0%'
            end
          end

          def compute_device(device)
            # If the "root" device, lookup the actual device from the kernel options
            # This is done because not all systems symlink /dev/root
            device = root_device if device == '/dev/root'
            device
          end

          def read_mounts # rubocop:disable Metrics/AbcSize
            require 'sys/filesystem'
            mounts = []
            Sys::Filesystem.mounts do |fs|
              device = compute_device(fs.name)
              filesystem = fs.mount_type
              path = fs.mount_point
              options = fs.options.split(',')

              next if path =~ %r{^/(proc|sys)} && filesystem != 'tmpfs' || filesystem == 'autofs'

              stats = Sys::Filesystem.stat(path)
              size_bytes = stats.bytes_total
              available_bytes = stats.bytes_available

              used_bytes = stats.bytes_used
              total_bytes = used_bytes + available_bytes
              capacity = compute_capacity(used_bytes, total_bytes)

              size = Facter::BytesToHumanReadable.convert(size_bytes)
              available = Facter::BytesToHumanReadable.convert(available_bytes)
              used = Facter::BytesToHumanReadable.convert(used_bytes)

              mounts << Hash[MOUNT_KEYS.zip(MOUNT_KEYS.map { |v| binding.local_variable_get(v) })]
            end
            @fact_list[:mountpoints] = mounts
          end
        end
      end
    end
  end
end
