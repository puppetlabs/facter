# Fact: uniqueid
#
# Purpose: 
#   Generates a string that should be unique for the host.
#
# Resolution: 
#   Uses 'hostid' to generate it.
#
# Caveats: 
#   Returns a host ID but it is not unique on all platforms e.g. Linux. It is unique 
#   on Solaris. It is being depricated "http://projects.puppetlabs.com/issues/3926".

Facter.add(:uniqueid) do
  setcode 'hostid'
  confine :kernel => %w{SunOS Linux AIX GNU/kFreeBSD}
end
