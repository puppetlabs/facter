# Fact: zones#
#
# Purpose:
#   Return the list of zones on the system and add one zones_ fact
#   for each zone with its state e.g. running, incomplete or installed.
#
# Resolution:
#   Uses 'usr/sbin/zoneadm list -cp' to get the list of zones in separate parsable
#   lines with delimeter being ':' which is used to split the line string and get
#   the zone details.
#
# Caveats:
#   We dont support below s10 where zones are not available.
require 'facter/util/solaris_zones'
if Facter.value(:kernel) == 'SunOS'
  Facter::Util::SolarisZones.add_facts
end
