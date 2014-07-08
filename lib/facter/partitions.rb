# Fact: partitions
#
# Purpose:
#   Return the details of the disk partitions.
#
# Resolution:
#   Parse the contents of `/sys/block/<device>/size` to receive the size (multiplying by 512 to correct for blocks-to-bytes).
#
# Caveats:
#   Only supports Linux 2.6+ at this time, due to the reliance on sysfs.
#

# Author: Chris Portman <chris@portman.net.au>

require 'facter'
require 'facter/util/partitions'

Facter.add(:partitions) do
  confine do
    Facter::Util::Partitions.available? ? true : nil
  end

  setcode do
    partitions = {}
    Facter::Util::Partitions.list.each do |part|
      details = {}
      details['uuid']       = Facter::Util::Partitions.uuid(part)
      details['size']       = Facter::Util::Partitions.size(part)
      details['mount']      = Facter::Util::Partitions.mount(part)
      details['filesystem'] = Facter::Util::Partitions.filesystem(part)
      details.reject! {|k,v| v.nil? || v.to_s.empty? }
      partitions[part] = details
    end
    partitions
  end
end
