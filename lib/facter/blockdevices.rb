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

# Author: Jason Gill <jasongill@gmail.com>

require 'facter'
require 'facter/util/blockdevices'

if Facter::Util::Blockdevices.available?
  Facter.add(:blockdevices) do
    setcode { Facter::Util::Blockdevices.devices.join(',') }
  end

  Facter::Util::Blockdevices.devices.each do |device|
    Facter.add("blockdevice_#{device}_size") do
      setcode { Facter::Util::Blockdevices.device_size(device) }
    end

    Facter.add("blockdevice_#{device}_vendor") do
      setcode { Facter::Util::Blockdevices.device_vendor(device) }
    end

    Facter.add("blockdevice_#{device}_model") do
      setcode { Facter::Util::Blockdevices.device_model(device)}
    end
  end
end
