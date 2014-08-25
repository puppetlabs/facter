# Fact: zones_<ZONE>
#
# Purpose:
#   Return the list of zones on the system and add one zones_ fact
#   for each zone with its state e.g. `running`, `incomplete`, or `installed`.
#
# Resolution:
#   Uses `usr/sbin/zoneadm list -cp` to get the list of zones in separate parsable
#   lines with delimeter being `:` which is used to split the line string and get
#   the zone details.
#
# Caveats:
#   Only supported on Solaris 10 and up.
#
require 'facter/util/solaris_zones'
if Facter.value(:kernel) == 'SunOS'
  Facter::Util::SolarisZones.add_facts
end
