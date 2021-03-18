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

          def read_mounts(fact_name) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
            @mounts = []
            @auto_home_paths = []

            Facter::Util::Resolvers::FilesystemHelper.read_mountpoints.each do |fs|
              if fs.name == 'auto_home'
                @auto_home_paths << fs.mount_point
                next
              end

              next if fs.mount_type == 'autofs'

              device = fs.name
              filesystem = fs.mount_type
              path = fs.mount_point
              options = fs.options.split(',').map(&:strip)

              stats = Facter::Util::Resolvers::FilesystemHelper.read_mountpoint_stats(path)
              size_bytes = stats.bytes_total.abs
              available_bytes = stats.bytes_available.abs

              used_bytes = stats.bytes_used.abs
              total_bytes = used_bytes + available_bytes
              capacity = Facter::Util::Resolvers::FilesystemHelper.compute_capacity(used_bytes, total_bytes)

              size = Facter::Util::Facts::UnitConverter.bytes_to_human_readable(size_bytes)
              available = Facter::Util::Facts::UnitConverter.bytes_to_human_readable(available_bytes)
              used = Facter::Util::Facts::UnitConverter.bytes_to_human_readable(used_bytes)

              @mounts << Hash[Facter::Util::Resolvers::FilesystemHelper::MOUNT_KEYS
                              .zip(Facter::Util::Resolvers::FilesystemHelper::MOUNT_KEYS
                .map { |v| binding.local_variable_get(v) })]
            end

            exclude_auto_home_mounts!

            @fact_list[:mountpoints] = @mounts
            @fact_list[fact_name]
          end
        end
      end
    end
  end
end
