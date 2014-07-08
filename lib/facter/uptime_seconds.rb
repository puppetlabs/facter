# Fact: uptime_seconds
#
# Purpose: Return just the number of seconds of uptime.
#
# Resolution:
#   Acquires the uptime in seconds via the 'seconds' key of the system_uptime fact,
#   which uses the `facter/util/uptime.rb` module to try a variety of methods to acquire
#   the uptime on Unix.
#
#   On Windows, the module calculates the uptime by the `LastBootupTime` Windows
#   management value.
#
# Caveats:
#

require 'facter/util/uptime'

Facter.add(:uptime_seconds) do
  setcode { Facter.value(:system_uptime)['seconds'] }
end
