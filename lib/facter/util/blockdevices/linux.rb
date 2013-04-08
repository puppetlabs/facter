module Facter::Util::Blockdevices

  module Linux
    # Only Linux 2.6+ kernels support sysfs which is required to easily get device details
    SYSFS_BLOCK_DIRECTORY = '/sys/block/'

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

  end

end
