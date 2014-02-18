# Fact: blockdevice_<devicename>_size
#
# Purpose:
#   Return the size of a block device in bytes
#
# Resolution:
#   Parse the contents of /sys/block/<device>/size to receive the size (multiplying by 512 to correct for blocks-to-bytes)
#
# Caveats:
#   Only supports Linux 2.6+ at this time, due to the reliance on sysfs
#

# Fact: blockdevice_<devicename>_vendor
#
# Purpose:
#   Return the vendor name of block devices attached to the system
#
# Resolution:
#   Parse the contents of /sys/block/<device>/device/vendor to retrieve the vendor for a device
#
# Caveats:
#   Only supports Linux 2.6+ at this time, due to the reliance on sysfs
#

# Fact: blockdevice_<devicename>_model
#
# Purpose:
#   Return the model name of block devices attached to the system
#
# Resolution:
#   Parse the contents of /sys/block/<device>/device/model to retrieve the model name/number for a device
#
# Caveats:
#   Only supports Linux 2.6+ at this time, due to the reliance on sysfs
#

# Fact: blockdevices
#
# Purpose:
#   Return a comma seperated list of block devices
#
# Resolution:
#   Retrieve the block devices that were identified and iterated over in the creation of the blockdevice_ facts
#
# Caveats:
#   Block devices must have been identified using sysfs information
#

# Fact: blockdevice_<devicename>_partitions
#
# Purpose:
#   Returns a comma separated list of partitions on the block device.
#
# Resolution:
#   Parses the contents of /sys/block/<device/<device>*
#
# Caveats:
#   Only supports Linux 2.6+ at this time, due to the reliance on sysfs
#

# Fact: blockdevice_<devicename><partition>_uuid
#
# Purpose:
#   Returns the UUID of the partitions on blockdevices.
#
# Resolution:
#   Parses /dev/disk/by-uuid and resolves the links back to the partitions in /dev
#
# Caveats:
#   Only supports Linux 2.6+ at this time, due to the reliance on sysfs
#

# Author: Jason Gill <jasongill@gmail.com>

require 'facter'

# Only Linux 2.6+ kernels support sysfs which is required to easily get device details
if Facter.value(:kernel) == 'Linux'

  sysfs_block_directory = '/sys/block/'

  blockdevices = []

  # This should prevent any non-2.6 kernels or odd machines without sysfs support from being investigated further
  if File.exist?(sysfs_block_directory)

    # Iterate over each file in the /sys/block/ directory and skip ones that do not have a device subdirectory
    Dir.entries(sysfs_block_directory).each do |device|
      sysfs_device_directory = sysfs_block_directory + device + "/device"
      next unless File.exist?(sysfs_device_directory)

      # Add the device to the blockdevices list, which is returned as it's own fact later on
      blockdevices << device

      sizefile = sysfs_block_directory + device + "/size"
      vendorfile = sysfs_device_directory + "/vendor"
      modelfile = sysfs_device_directory + "/model"
      partitions = Dir.glob(sysfs_block_directory + device + "/#{device}*").map { |d| File.basename(d) }
      devdisk_by_uuid_directory = '/dev/disk/by-uuid/'

      if File.exist?(sizefile)
        Facter.add("blockdevice_#{device}_size".to_sym) do
          setcode { IO.read(sizefile).strip.to_i * 512 }
        end
      end

      if File.exist?(vendorfile)
        Facter.add("blockdevice_#{device}_vendor".to_sym) do
          setcode { IO.read(vendorfile).strip }
        end
      end

      if File.exist?(modelfile)
        Facter.add("blockdevice_#{device}_model".to_sym) do
          setcode { IO.read(modelfile).strip }
        end
      end

      unless partitions.empty?
        Facter.add("blockdevice_#{device}_partitions") do
          setcode { partitions.join(',') }
        end
      end

      partitions.each do |part|
        Facter.add("blockdevice_#{part}_uuid") do
          setcode do
            uuid = nil
            if File.directory?(devdisk_by_uuid_directory)
              Dir.entries(devdisk_by_uuid_directory).each do |file|
                qualified_file = "#{devdisk_by_uuid_directory}#{file}"

                #A uuid is 16 octets long (RFC4122) which is 32hex chars + 4 '-'s
                next unless file.length == 36
                next unless File.symlink?(qualified_file)
                next unless File.readlink(qualified_file).match(%r[(?:\.\./\.\./|/dev/)#{part}$])

                uuid = file
              end
            end
            uuid
          end
        end
      end
    end
  end

  # Return a comma-seperated list of block devices found
  unless blockdevices.empty?
    Facter.add(:blockdevices) do
      setcode { blockdevices.sort.join(',') }
    end
  end
end
