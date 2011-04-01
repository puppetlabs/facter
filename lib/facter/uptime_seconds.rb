# Fact: uptime_seconds
#
# Purpose: Return purely number of seconds of uptime.
#
# Resolution:
#   Using the 'facter/util/uptime.rb' module, try a verity of methods to acquire
#   the uptime on Unix.
#
#   On Windows, the module calculates the uptime by the "LastBootupTime" Windows
#   management value.
#
# Caveats:
#

require 'facter/util/uptime'

Facter.add(:uptime_seconds) do
  setcode { Facter::Util::Uptime.get_uptime_seconds_unix }
end

Facter.add(:uptime_seconds) do
  confine :kernel => :windows
  setcode { Facter::Util::Uptime.get_uptime_seconds_win }
end
