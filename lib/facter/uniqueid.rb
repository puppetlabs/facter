# Fact: uniqueid
#
# Purpose: To get a unique ID.
#
# Resolution: Uses 'hostid' to generate it.
#
# Caveats: Returns a host ID but it is not unique.
#
Facter.add(:uniqueid) do
  setcode 'hostid'
  confine :kernel => %w{SunOS Linux AIX GNU/kFreeBSD}
end
