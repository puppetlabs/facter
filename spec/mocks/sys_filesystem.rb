# frozen_string_literal: true

module Sys
  class Filesystem
    def self.mounts; end

    class Mount
      # The name of the mounted resource.
      attr_accessor :name

      # The mount point/directory.
      attr_accessor :mount_point

      # The type of filesystem mount, e.g. ufs, nfs, etc.
      attr_accessor :mount_type

      # A list of comma separated options for the mount, e.g. nosuid, etc.
      attr_accessor :options

      # The time the filesystem was mounted. May be nil.
      attr_accessor :mount_time

      # The dump frequency in days. May be nil.
      attr_accessor :dump_frequency

      # The pass number of the filessytem check. May be nil.
      attr_accessor :pass_number
    end

    class Stat
      # The path of the filesystem.
      attr_accessor :path

      # The preferred system block size.
      attr_accessor :block_size

      # The fragment size, i.e. fundamental filesystem block size.
      attr_accessor :fragment_size

      # The total number of +fragment_size+ blocks in the filesystem.
      attr_accessor :blocks

      # The total number of free blocks in the filesystem.
      attr_accessor :blocks_free

      # The number of free blocks available to unprivileged processes.
      attr_accessor :blocks_available

      # The total number of files/inodes that can be created.
      attr_accessor :files

      # The total number of files/inodes on the filesystem.
      attr_accessor :files_free

      # The number of free files/inodes available to unprivileged processes.
      attr_accessor :files_available

      # The filesystem identifier.
      attr_accessor :filesystem_id

      # A bit mask of flags.
      attr_accessor :flags

      # The maximum length of a file name permitted on the filesystem.
      attr_accessor :name_max

      # The filesystem type, e.g. UFS.
      attr_accessor :base_type

      # Returns the total space on the partition.
      def bytes_total
        blocks * fragment_size
      end

      # Returns the total amount of free space on the partition.
      def bytes_free
        blocks_free * fragment_size
      end

      # Returns the amount of free space available to unprivileged processes.
      def bytes_available
        blocks_available * fragment_size
      end

      # Returns the total amount of used space on the partition.
      def bytes_used
        bytes_total - bytes_free
      end

      # Returns the percentage of the partition that has been used.
      def percent_used
        100 - (100.0 * bytes_free.to_f / bytes_total.to_f)
      end
    end
  end
end
