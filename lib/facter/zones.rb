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

Facter.add("zones") do
  confine :kernel => :sunos
  fmt = [:id, :name, :status, :path, :uuid, :brand, :iptype]
  l = Facter::Util::Resolution.exec('/usr/sbin/zoneadm list -cp').collect{|l|l.split(':')}.each do |val|
      fmt.each_index do |i|
        Facter.add "zone_%s_%s" % [val[1], fmt[i]] do
          setcode { val[i] }
        end
      end
  end
  setcode { l.length }
end

