module Facter::Util::Blockdevices

  module Linux
    # Only Linux 2.6+ kernels support sysfs which is required to easily get device details
    SYSFS_BLOCK_DIRECTORY     = '/sys/block/'
    DEVDISK_BY_UUID_DIRECTORY = '/dev/disk/by-uuid/'

    def self.read_if_exists(f)
      if File.exist?(f)
        IO.read(f).strip
      else
        nil
      end
    end

    def self.device_vendor(device_name)
      read_if_exists device_dir(device_name) + "/vendor"
    end

    def self.device_model(device_name)
      read_if_exists device_dir(device_name) + "/model"
    end

    def self.device_size(device_name)
      content = read_if_exists SYSFS_BLOCK_DIRECTORY + device_name + "/size"
      if content
        content.to_i * 512
      else
        nil
      end
    end

    def self.devices
      # This should prevent any non-2.6 kernels or odd machines
      # without sysfs support from being investigated further
      if File.exist?(SYSFS_BLOCK_DIRECTORY)
        # Iterate over each file in the /sys/block/ directory and keep
        # those that have a device subdirectory
        Dir.entries(SYSFS_BLOCK_DIRECTORY).find_all do |f|
          File.exist?(device_dir(f))
        end
      else
        []
      end
    end

    def self.device_dir(device)
      SYSFS_BLOCK_DIRECTORY + device + "/device"
    end

    def self.device_partitions(device)
      Dir.glob( SYSFS_BLOCK_DIRECTORY + device + "/#{device}*" ).map do |d|
        File.basename(d)
      end
    end

    def self.partition_uuid(partition)
      if File.directory?(DEVDISK_BY_UUID_DIRECTORY)
        Dir.entries(DEVDISK_BY_UUID_DIRECTORY).each do |file|
          uuid = nil
          qualified_file = "#{DEVDISK_BY_UUID_DIRECTORY}#{file}"

          #A uuid is 16 octets long (RFC4122) which is 32hex chars + 4 '-'s
          next unless file.length == 36
          next unless File.symlink?(qualified_file)
          next unless File.readlink(qualified_file).match(%r[(?:\.\./\.\./|/dev/)#{partition}$])

          uuid = file
          return uuid
        end
      end

      uuid
    end

  end

end
