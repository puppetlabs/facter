# Fact: pid
#
# Purpose: Returns the Process ID.
#
# Resolution: Gets the Process ID.
#
# Caveats:
#

Facter.add("pid') do
  setcode {Process.pid}
end
