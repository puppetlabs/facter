# frozen_string_literal: true

module Facter
  module FilesystemHelper
    MOUNT_KEYS = %i[device filesystem path options
                    available available_bytes size
                    size_bytes used used_bytes capacity].freeze

    def self.read_mountpoints
      require 'sys/filesystem'
      Sys::Filesystem.mounts
    end

    def self.read_mountpoint_stats(path)
      require 'sys/filesystem'
      Sys::Filesystem.stat(path)
    end

    def self.compute_capacity(used, total)
      if used == total
        '100%'
      elsif used.positive?
        "#{format('%.2f', 100.0 * used.to_f / total.to_f)}%"
      else
        '0%'
      end
    end
  end
end
